# frozen_string_literal: true

#  Copyright (c) 2012-2024, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Person do
  context "canton_label" do
    it "is blank for nil value" do
      expect(Person.new.canton_label).to be_blank
    end

    it "is blank for blank value" do
      expect(Fabricate.build(:person, canton: "").canton_label).to be_blank
    end

    it "is locale specific value for valid key" do
      expect(Fabricate.build(:person, canton: "be").canton_label).to eq "Bern"
    end
  end

  context "#number" do
    it "creates automatic number for new people" do
      person1 = Fabricate.build(:person, first_name: "John")
      expect(person1.save).to be true
      expect(person1.number).to eq Person::AUTOMATIC_NUMBER_RANGE.first

      person2 = Fabricate.build(:person, first_name: "John")
      person2.save
      expect(person2.number).to eq Person::AUTOMATIC_NUMBER_RANGE.first + 1
    end

    it "keeps automatic number when updating people" do
      person = Fabricate.build(:person, first_name: "John")
      expect(person.save).to be true
      expect(person.number).to eq Person::AUTOMATIC_NUMBER_RANGE.first

      person.number = 1
      expect(person.save).to be true
      expect(person.number).to eq Person::AUTOMATIC_NUMBER_RANGE.first
    end

    it "sets manual number on create when flag is set" do
      person = Fabricate.build(:person, first_name: "John", number: 1, manual_number: true)
      expect(person.save).to be true
      expect(person.number).to eq 1
    end

    it "keeps manual number on update when flag is set" do
      person = Fabricate.build(:person, first_name: "John", number: 1, manual_number: true)
      expect(person.save).to be true

      person.last_name = "Lenon"
      person.save
      expect(person.number).to eq 1
    end

    it "changes manual number on update when flag is set" do
      person = Fabricate.build(:person, first_name: "John", number: 1, manual_number: true)
      expect(person.save).to be true

      person.number = 2
      expect(person.save).to be true
      expect(person.number).to be 2
    end

    it "creates automatic number on update when flag is not set" do
      person = Fabricate.build(:person, first_name: "John", number: 1, manual_number: true)
      expect(person.save).to be true

      person.manual_number = false
      expect(person.save).to be true
      expect(person.number).to eq Person::AUTOMATIC_NUMBER_RANGE.first
    end

    it "must be unique" do
      person1 = Fabricate.build(:person, first_name: "John", number: 1, manual_number: true)
      person2 = Fabricate.build(:person, first_name: "Jack", number: 1, manual_number: true)
      expect(person1).to be_valid
      expect(person2).to be_valid
      expect(person1.save).to be true
      expect(person2.save).to be false
    end

    it "fails when manual number is at beginning of invalid range" do
      person = Fabricate.build(:person, first_name: "John",
        number: Person::AUTOMATIC_NUMBER_RANGE.first, manual_number: true)
      expect(person).not_to be_valid
    end

    it "fails when manual number is at end of invalid range" do
      person = Fabricate.build(:person, first_name: "John",
        number: Person::AUTOMATIC_NUMBER_RANGE.last - 1, manual_number: true)
      expect(person).not_to be_valid
    end

    it "is valid when manual number is just after invalid range" do
      person = Fabricate.build(:person, first_name: "John",
        number: Person::AUTOMATIC_NUMBER_RANGE.last, manual_number: true)
      expect(person).to be_valid
    end

    context "manual" do
      it 'handles "0" strings correctly' do
        person = Fabricate.build(:person, manual_number: "0")
        expect(person.manual_number).to be_falsey
      end

      it 'handles "1" strings correctly' do
        person = Fabricate.build(:person, manual_number: "1")
        expect(person.manual_number).to be_truthy
      end

      it "handles 1 integer correctly" do
        person = Fabricate.build(:person, manual_number: 1)
        expect(person.manual_number).to be_truthy
      end

      it "handles 0 integer correctly" do
        person = Fabricate.build(:person, manual_number: 0)
        expect(person.manual_number).to be_falsey
      end

      it "handles nil correctly with manual number" do
        person = Fabricate.build(:person, number: 1)
        expect(person.manual_number).to be_truthy
      end

      it "handles nil correctly with automatic number" do
        person = Fabricate.build(:person, number: Person::AUTOMATIC_NUMBER_RANGE.first)
        expect(person.manual_number).to be_falsey
      end

      it "generates automatic number if manual is nil" do
        person = Fabricate.build(:person, first_name: "John",
          number: Person::AUTOMATIC_NUMBER_RANGE.first + 10)
        person.save
        expect(person.number).to eq Person::AUTOMATIC_NUMBER_RANGE.first
      end

      it "keeps manual number if manual is nil" do
        person = Fabricate.build(:person, first_name: "John", number: 1)
        person.save
        expect(person.number).to eq 1
      end

      it "generates automatic number if manual is nil and old number existed" do
        person = Fabricate.build(:person, first_name: "John", number: 1)
        person.save
        expect(person.number).to eq 1

        person.number = Person::AUTOMATIC_NUMBER_RANGE.first + 10
        person.manual_number = nil
        person.save
        expect(person.number).to eq Person::AUTOMATIC_NUMBER_RANGE.first
      end

      it "keeps automatic number if manual is nil and old number existed" do
        person = Fabricate.build(:person, first_name: "John")
        person.save
        expect(person.number).to eq Person::AUTOMATIC_NUMBER_RANGE.first

        person.number = Person::AUTOMATIC_NUMBER_RANGE.first + 10
        person.manual_number = nil
        person.save
        expect(person.number).to eq Person::AUTOMATIC_NUMBER_RANGE.first
      end
    end
  end

  context "updating addresses" do
    it "sets blank address fields to main values" do
      person = create

      expect(person.reload.correspondence_general_first_name).to eq "John"
      expect(person.reload.correspondence_general_last_name).to eq "Lennon"
      expect(person.correspondence_course_address).to eq "Pennylane"
      expect(person.billing_general_town).to eq "Liverpool"
      expect(person.billing_course_zip_code).to eq 60601
      expect(person.billing_course_country).to eq "US"
    end

    it "sets same_as_main according to values of address fields" do
      person = create
      person.update!(correspondence_general_same_as_main: false,
        correspondence_general_first_name: "Working class hero")

      expect(person.reload.full_name).to eq "John Lennon"
      expect(person.correspondence_general_first_name).to eq "Working class hero"
      expect(person.correspondence_general_same_as_main).to be_falsey
    end

    def create(attrs = {})
      Fabricate(:person, attrs.merge(first_name: "John", last_name: "Lennon",
        street: "Pennylane", housenumber: nil,
        zip_code: "60601", town: "Liverpool", country: "US"))
    end
  end

  context "grouped_active_membership_roles" do
    it "should only include Group::Aktivmitglieder" do
      person = Fabricate.build(:person, first_name: "John")
      Fabricate(Group::Dachverein::Geschaeftsfuehrung.name.to_sym,
        person: person, group: groups(:dachverein))
      Fabricate(Group::Regionalverein::Praesident.name.to_sym,
        person: person, group: groups(:seeland))
      active = Fabricate(Group::Aktivmitglieder::Aktivmitglied.name.to_sym,
        person: person, group: groups(:aktiv))

      expect(person.grouped_active_membership_roles).to eq(active.group => [active])
    end
  end

  context "disabled_person_reference" do
    let(:person) do
      Fabricate.build(:person, {
        disabled_person_first_name: "aaa",
        disabled_person_last_name: "bbb",
        disabled_person_address: "ccc",
        disabled_person_zip_code: 1234,
        disabled_person_town: "ddd",
        disabled_person_birthday: "01.02.2003"
      })
    end

    it "should store the disabled person fields if true" do
      person.disabled_person_reference = true
      person.save!

      expect(person.disabled_person_reference).to be_truthy
      expect(person.disabled_person_first_name).to eq "aaa"
      expect(person.disabled_person_last_name).to eq "bbb"
      expect(person.disabled_person_address).to eq "ccc"
      expect(person.disabled_person_zip_code).to eq 1234
      expect(person.disabled_person_town).to eq "ddd"
      expect(person.disabled_person_birthday).to eq Date.new(2003, 2, 1)
    end

    it "should reset the disabled person fields if false" do
      person.disabled_person_reference = false
      person.save!

      expect(person.disabled_person_reference).to be_falsey
      expect(person.disabled_person_first_name).to be_nil
      expect(person.disabled_person_last_name).to be_nil
      expect(person.disabled_person_address).to be_nil
      expect(person.disabled_person_zip_code).to be_nil
      expect(person.disabled_person_town).to be_nil
      expect(person.disabled_person_birthday).to be_nil
    end
  end

  Person::ADDRESS_TYPES.each do |type|
    context "#{type}_zip_code" do
      let(:zip_code) { :"#{type}_zip_code" }
      let(:country) { :"#{type}_country" }

      it "allows more than 4 digits for international plz" do
        expect(new_person(zip_code => 90210, country => "US")).to be_valid
      end

      it "rejects more than 4 digits for swiss plz" do
        expect(new_person(zip_code => 90210)).to have(1).error_on(zip_code)
        expect(new_person(zip_code => 9021)).to be_valid
      end
    end

    def new_person(attrs)
      Fabricate.build(:person, attrs.merge(first_name: "John")).tap { |p| p.valid? }
    end
  end

  context "validates, that a" do
    context "company" do
      subject(:company) { Fabricate(:person, {company: true, company_name: "ACME Corp"}) }

      it { expect(company).to be_company }

      it "has a company_name" do
        expect { company.company_name = nil }.to change { company.valid? }.from(true).to(false)
      end
    end

    context "person" do
      subject(:nicknamed_person) { Fabricate(:person, {company: false, nickname: "Nick"}) }

      subject(:named_person) { Fabricate(:person) }

      it { expect(nicknamed_person).to_not be_company }
      it { expect(named_person).to_not be_company }

      it "has a first_name and a last_name" do # long version once, shorter specs to follow
        nicknamed_person.first_name = nil
        nicknamed_person.last_name = nil

        expect(nicknamed_person.first_name).to be_blank
        expect(nicknamed_person.last_name).to be_blank
        expect(nicknamed_person).to_not be_valid

        nicknamed_person.first_name = "Tom"
        nicknamed_person.last_name = "Tester"

        expect(nicknamed_person).to be_valid
      end

      it "has not only a last_name" do
        expect { nicknamed_person.first_name = nil }.to change {
          nicknamed_person.valid?
        }.from(true).to(false)
      end

      it "has not only a first_name" do
        expect { nicknamed_person.last_name = nil }.to change {
          nicknamed_person.valid?
        }.from(true).to(false)
      end

      it "has a street" do
        expect { named_person.street = nil }.to change { named_person.valid? }.from(true).to(false)
      end

      it "has a zip_code" do
        expect { named_person.zip_code = nil }.to change {
          named_person.valid?
        }.from(true).to(false)
      end

      it "has a town" do
        expect { named_person.town = nil }.to change { named_person.valid? }.from(true).to(false)
      end

      it "has a country" do
        expect { named_person.country = nil }.to change { named_person.valid? }.from(true).to(false)
      end

      it "has a correspondence_language" do
        expect { named_person.correspondence_language = nil }.to change {
          named_person.valid?
        }.from(true).to(false)
      end

      it "has a language" do
        expect { named_person.language = nil }.to change {
          named_person.valid?
        }.from(true).to(false)
      end
    end
  end
end
