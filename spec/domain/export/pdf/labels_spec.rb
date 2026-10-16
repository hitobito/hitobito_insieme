# frozen_string_literal: true

#  Copyright (c) 2014-2026, Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Export::Pdf::Labels do
  let(:person) { people(:top_leader) }

  let(:labels) { Export::Pdf::Labels.new(Fabricate(:label_format), category_key: address_type) }

  subject { labels.send(:address, person, to_name(person)) }

  def to_name(contactable)
    Export::Tabular::People::HouseholdRow.new(contactable).name
  end

  before do
    person.update!(
      street: "My Street",
      housenumber: nil,
      town: "Bern",
      zip_code: "3007"
    )
    Fabricate(:additional_address,
      contactable: person,
      category: contact_account_categories(:additional_address_person_mutter),
      uses_contactable_name: false,
      first_name: "Course",
      last_name: "Leader",
      organization: true,
      organization_name: "Chiefs Inc",
      street: "Course Street",
      housenumber: nil,
      zip_code: "3030",
      town: "Wabern",
      country: "CH")
  end

  context "for person" do
    context "for main address" do
      let(:address_type) { "main" }

      it "renders correct address" do
        is_expected.to eq "Top Leader\nMy Street\n3007 Bern\n"
      end
    end

    context "for additional address" do
      let(:address_type) { "mutter" }

      it "renders correct address" do
        is_expected.to eq "Chiefs Inc\nCourse Leader\nCourse Street\n3030 Wabern\n"
      end
    end
  end

  context "for company person" do
    let(:company) { true }
    let(:company_name) { "Chiefs Incorporated" }

    before do
      person.update(company: company, company_name: company_name)
    end

    context "for main address" do
      let(:address_type) { "main" }

      it "has assumptions" do
        expect(person.first_name).to eq "Top"
        expect(person.last_name).to eq "Leader"
        expect(person.full_name).to eq "Top Leader"
        expect(person.company_name).to eq "Chiefs Incorporated"
        expect(person.company).to be_truthy
      end

      context "with a company-name set" do
        let(:company_name) { "Chiefs Incorporated" }
        let(:address_type) { "main" }

        context "when marked as a company" do
          let(:company) { true }

          it "renders company_name" do
            is_expected.to eq "Chiefs Incorporated\nTop Leader\nMy Street\n3007 Bern\n"
          end
        end

        context "when not marked as a company" do
          let(:company) { false }

          it "does also render company_name" do
            is_expected.to eq "Chiefs Incorporated\nTop Leader\nMy Street\n3007 Bern\n"
          end
        end
      end

      context "with no company-name set" do
        let(:company_name) { nil }
        let(:address_type) { "main" }

        context "when marked as a company" do
          let(:company) { true }

          it "does not render company_name" do
            is_expected.to eq "Top Leader\nMy Street\n3007 Bern\n"
          end
        end

        context "when not marked as a company" do
          let(:company) { false }

          it "does also not render company_name" do
            is_expected.to eq "Top Leader\nMy Street\n3007 Bern\n"
          end
        end
      end
    end

    context "for additional address" do
      let(:address_type) { "mutter" }

      it "renders correct address" do
        is_expected.to eq "Chiefs Inc\nCourse Leader\nCourse Street\n3030 Wabern\n"
      end
    end
  end
end
