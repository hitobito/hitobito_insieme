# frozen_string_literal: true

#  Copyright (c) 2026, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"
require_relative "../../db/migrate/20261016142903_migrate_insieme_addresses_to_additional_addresses"

describe MigrateInsiemeAddressesToAdditionalAddresses, type: :migration do
  let(:migration_version) { 20261016142903 }
  let(:migration_context) { ActiveRecord::Base.connection_pool.migration_context }
  let(:person) { people(:top_leader) }

  def connection
    ActiveRecord::Base.connection
  end

  def add_insieme_address_columns
    described_class::ADDRESS_TYPES.each do |type|
      connection.execute(<<~SQL)
        ALTER TABLE people
          ADD COLUMN IF NOT EXISTS #{type}_salutation varchar,
          ADD COLUMN IF NOT EXISTS #{type}_first_name varchar,
          ADD COLUMN IF NOT EXISTS #{type}_last_name varchar,
          ADD COLUMN IF NOT EXISTS #{type}_company_name varchar,
          ADD COLUMN IF NOT EXISTS #{type}_company boolean NOT NULL DEFAULT FALSE,
          ADD COLUMN IF NOT EXISTS #{type}_address text,
          ADD COLUMN IF NOT EXISTS #{type}_zip_code integer,
          ADD COLUMN IF NOT EXISTS #{type}_town varchar,
          ADD COLUMN IF NOT EXISTS #{type}_country varchar,
          ADD COLUMN IF NOT EXISTS #{type}_same_as_main boolean DEFAULT TRUE,
          ADD COLUMN IF NOT EXISTS #{type}_label varchar(20)
      SQL
    end
  end

  def set_address(type, person: self.person, **attrs)
    attrs = {same_as_main: false, first_name: "Max", last_name: "Muster",
             address: "Musterweg 2", zip_code: 8000, town: "Zürich", country: "CH"}.merge(attrs)
    assignments = attrs.map { |field, value| "#{type}_#{field} = #{connection.quote(value)}" }
    connection.execute("UPDATE people SET #{assignments.join(", ")} WHERE id = #{person.id}")
  end

  def migrate
    migration_context.up(migration_version)
    AdditionalAddress.reset_column_information
    Person.reset_column_information
  end

  def addresses
    AdditionalAddress.where(contactable: person).includes(:category).order(:id)
  end

  before do
    ActiveRecord::Migration.verbose = false
    connection.execute("DELETE FROM schema_migrations WHERE version = '#{migration_version}'")
    add_insieme_address_columns
    connection.schema_cache.clear!
    ActiveRecord::Base.descendants.each(&:reset_column_information)
  end

  after do
    connection.schema_cache.clear!
    ActiveRecord::Base.descendants.each(&:reset_column_information)
    ActiveRecord::Migration.verbose = true
  end

  it "does not migrate addresses same as main" do
    expect { migrate }.not_to change { AdditionalAddress.count }
  end

  it "removes the insieme address columns" do
    migrate

    expect(Person.column_names.grep(/_(general|course)_/)).to be_empty
  end

  context "without categories" do
    before do
      ContactAccountCategory.where(contact_account_type: "AdditionalAddress",
        contactable_type: "Person").delete_all
    end

    it "removes the insieme address columns if no address needs migrating" do
      migrate

      expect(Person.column_names.grep(/_(general|course)_/)).to be_empty
    end

    it "fails if an address needs migrating" do
      set_address(:billing_general)

      expect { migrate }.to raise_error(/Missing AdditionalAddress categories: invoices, other/)
    end
  end

  context "billing address" do
    it "migrates billing_general with invoices category and original label" do
      set_address(:billing_general, label: "Beistand", company: true, company_name: "Firma AG",
        address: "Alte Bahnhofstrasse 12a")

      migrate

      expect(addresses.size).to eq 1
      address = addresses.first
      expect(address.category.key).to eq "invoices"
      expect(address.label).to eq "Beistand"
      expect(address).to have_attributes(
        first_name: "Max", last_name: "Muster", organization: true,
        organization_name: "Firma AG", uses_contactable_name: false, public: true,
        street: "Alte Bahnhofstrasse", housenumber: "12a",
        zip_code: "8000", town: "Zürich", country: "CH"
      )
    end

    it "prefers billing_general over billing_course" do
      set_address(:billing_general, town: "General")
      set_address(:billing_course, town: "Course")

      migrate

      expect(addresses.map(&:town)).to eq ["General"]
    end

    it "falls back to billing_course with blank label" do
      set_address(:billing_course, label: " ")

      migrate

      expect(addresses.size).to eq 1
      expect(addresses.first.category.key).to eq "invoices"
      expect(addresses.first.label).to be_nil
    end
  end

  context "correspondence address" do
    it "maps label case insensitively to category" do
      set_address(:correspondence_general, label: " mutter ")

      migrate

      expect(addresses.first.category.key).to eq "mutter"
      expect(addresses.first.label).to eq "Korrespondenz Allgemein"
    end

    it "maps unknown label to other and keeps it in the label" do
      set_address(:correspondence_course, label: "Privat")

      migrate

      expect(addresses.first.category.key).to eq "other"
      expect(addresses.first.label).to eq "Korrespondenz Kurse (Privat)"
    end

    it "maps missing label to other" do
      set_address(:correspondence_course, label: nil)

      migrate

      expect(addresses.first.category.key).to eq "other"
      expect(addresses.first.label).to eq "Korrespondenz Kurse"
    end

    it "migrates both correspondence addresses of the same category" do
      set_address(:correspondence_general, label: "Vater")
      set_address(:correspondence_course, label: "Vater")

      migrate

      expect(addresses.map { |a| [a.category.key, a.label] }).to eq [
        ["vater", "Korrespondenz Allgemein"],
        ["vater", "Korrespondenz Kurse"]
      ]
    end
  end

  context "address fields" do
    it "keeps single word address as street" do
      set_address(:correspondence_general, address: "Postfach")

      migrate

      expect(addresses.first).to have_attributes(street: "Postfach", housenumber: nil)
    end

    it "strips surrounding line breaks before splitting housenumber" do
      set_address(:correspondence_general, address: "\r\nSchweighofstrasse 48\r\n\r\n")

      migrate

      expect(addresses.first).to have_attributes(street: "Schweighofstrasse", housenumber: "48")
    end

    it "keeps overlong last word in street" do
      set_address(:correspondence_general, address: "Weg Zwanzigzeichenundmehr")

      migrate

      expect(addresses.first).to have_attributes(street: "Weg Zwanzigzeichenundmehr",
        housenumber: nil)
    end

    it "falls back to person name and country if missing" do
      person.update_columns(country: "DE")
      set_address(:correspondence_general, first_name: nil, last_name: "", country: nil)

      migrate

      expect(addresses.first).to have_attributes(
        first_name: person.first_name, last_name: person.last_name,
        uses_contactable_name: true, country: "DE"
      )
    end
  end
end
