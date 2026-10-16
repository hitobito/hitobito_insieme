# frozen_string_literal: true

#  Copyright (c) 2026, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class MigrateInsiemeAddressesToAdditionalAddresses < ActiveRecord::Migration[8.0]
  ADDRESS_TYPES = %w[correspondence_general billing_general correspondence_course
    billing_course].freeze

  ADDRESS_FIELDS = %w[salutation first_name last_name company_name company address zip_code town
    country same_as_main label].freeze

  CORRESPONDENCE_LABELS = {
    "correspondence_general" => "Korrespondenz Allgemein",
    "correspondence_course" => "Korrespondenz Kurse"
  }.freeze

  LABEL_KEY_MAPPING = {
    "arbeit" => "work",
    "mutter" => "mutter",
    "vater" => "vater",
    "beistand" => "beistand",
    "wohngruppe" => "wohngruppe",
    "wohnheim" => "wohnheim"
  }.freeze

  REQUIRED_CATEGORY_KEYS = %w[invoices other].freeze

  def up
    return unless column_exists?(:people, :billing_general_address)

    # A fresh database is set up from the core schema, so it has no categories,
    # but also no addresses to migrate.
    if addresses_to_migrate?
      migrate_billing_addresses
      CORRESPONDENCE_LABELS.each_key { |type| migrate_correspondence_addresses(type) }
    end
    remove_address_columns
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def addresses_to_migrate?
    conditions = ADDRESS_TYPES.map { |type| "people.#{type}_same_as_main IS NOT TRUE" }
    select_value("SELECT EXISTS (SELECT 1 FROM people WHERE #{conditions.join(" OR ")})")
  end

  def migrate_billing_addresses
    insert_additional_addresses(
      "billing_general",
      category_id: category_ids.fetch("invoices"),
      label: "NULLIF(TRIM(people.billing_general_label), '')",
      condition: "people.billing_general_same_as_main IS NOT TRUE"
    )
    insert_additional_addresses(
      "billing_course",
      category_id: category_ids.fetch("invoices"),
      label: "NULLIF(TRIM(people.billing_course_label), '')",
      condition: "people.billing_general_same_as_main IS TRUE AND " \
                 "people.billing_course_same_as_main IS NOT TRUE"
    )
  end

  def migrate_correspondence_addresses(type)
    category_id = "COALESCE(#{label_category_sql(type)}, #{category_ids.fetch("other")})"
    insert_additional_addresses(
      type,
      category_id: category_id,
      label: correspondence_label_sql(type, category_id),
      condition: "people.#{type}_same_as_main IS NOT TRUE"
    )
  end

  def label_category_sql(type)
    whens = LABEL_KEY_MAPPING.filter_map do |label, key|
      "WHEN #{quote(label)} THEN #{category_ids[key]}" if category_ids.key?(key)
    end
    return "NULL" if whens.empty?

    "CASE LOWER(TRIM(people.#{type}_label)) #{whens.join(" ")} END"
  end

  def correspondence_label_sql(type, category_id)
    original_label = "NULLIF(TRIM(people.#{type}_label), '')"
    prefix = quote(CORRESPONDENCE_LABELS.fetch(type))
    <<~SQL
      CASE
        WHEN #{category_id} = #{category_ids.fetch("other")} AND #{original_label} IS NOT NULL
          THEN #{prefix} || ' (' || #{original_label} || ')'
        ELSE #{prefix}
      END
    SQL
  end

  def insert_additional_addresses(type, category_id:, label:, condition:) # rubocop:disable Metrics/MethodLength
    address = "TRIM(REGEXP_REPLACE(COALESCE(people.#{type}_address, ''), '\\s+', ' ', 'g'))"
    last_word = "SUBSTRING(#{address} FROM ' (\\S+)$')"
    split = "#{last_word} IS NOT NULL AND LENGTH(#{last_word}) <= 20"
    no_name = "COALESCE(people.#{type}_first_name, '') = '' AND " \
              "COALESCE(people.#{type}_last_name, '') = '' AND " \
              "NOT (people.#{type}_company AND COALESCE(people.#{type}_company_name, '') <> '')"

    execute(<<~SQL)
      INSERT INTO additional_addresses (
        contactable_type, contactable_id, category_id, label, public, uses_contactable_name,
        first_name, last_name, organization_name, organization,
        street, housenumber, zip_code, town, country
      )
      SELECT
        'Person', people.id, #{category_id}, #{label}, TRUE, (#{no_name}),
        CASE WHEN #{no_name} THEN people.first_name ELSE people.#{type}_first_name END,
        CASE WHEN #{no_name} THEN people.last_name ELSE people.#{type}_last_name END,
        CASE WHEN #{no_name} THEN people.company_name ELSE people.#{type}_company_name END,
        CASE WHEN #{no_name} THEN people.company ELSE people.#{type}_company END,
        CASE WHEN #{split} THEN REGEXP_REPLACE(#{address}, ' \\S+$', '') ELSE #{address} END,
        CASE WHEN #{split} THEN #{last_word} END,
        COALESCE(people.#{type}_zip_code::text, ''),
        COALESCE(people.#{type}_town, ''),
        COALESCE(NULLIF(TRIM(people.#{type}_country), ''), NULLIF(TRIM(people.country), ''), 'CH')
      FROM people
      WHERE #{condition}
    SQL
  end

  def category_ids
    @category_ids ||= begin
      ids = select_rows(<<~SQL).to_h
        SELECT key, id FROM contact_account_categories
        WHERE contact_account_type = 'AdditionalAddress' AND contactable_type = 'Person'
      SQL
      missing = REQUIRED_CATEGORY_KEYS - ids.keys
      raise "Missing AdditionalAddress categories: #{missing.join(", ")}" if missing.any?

      ids
    end
  end

  def remove_address_columns
    change_table :people, bulk: true do |t|
      ADDRESS_TYPES.product(ADDRESS_FIELDS).each do |type, field|
        t.remove :"#{type}_#{field}"
      end
    end
  end
end
