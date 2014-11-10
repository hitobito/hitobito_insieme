# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Person do

  context 'canton_value' do

    it 'is blank for nil value' do
      Person.new.canton_value.should be_blank
    end

    it 'is blank for blank value' do
      Person.new(canton: '').canton_value.should be_blank
    end

    it 'is locale specific value for valid key' do
      Person.new(canton: 'be').canton_value.should eq 'Bern'
    end
  end

  context '#number' do
    it 'creates automatic number for new people' do
      person1 = Person.new(first_name: 'John')
      person1.save.should be true
      person1.number.should eq Person::AUTOMATIC_NUMBER_RANGE.first

      person2 = Person.new(first_name: 'John')
      person2.save
      person2.number.should eq Person::AUTOMATIC_NUMBER_RANGE.first + 1
    end

    it 'keeps automatic number when updating people' do
      person = Person.new(first_name: 'John')
      person.save.should be true
      person.number.should eq Person::AUTOMATIC_NUMBER_RANGE.first

      person.number = 1
      person.save.should be true
      person.number.should eq Person::AUTOMATIC_NUMBER_RANGE.first
    end

    it 'sets manual number on create when flag is set' do
      person = Person.new(first_name: 'John', number: 1, manual_number: true)
      person.save.should be true
      person.number.should eq 1
    end

    it 'keeps manual number on update when flag is set' do
      person = Person.new(first_name: 'John', number: 1, manual_number: true)
      person.save.should be true

      person.last_name = 'Lenon'
      person.save
      person.number.should eq 1
    end

    it 'changes manual number on update when flag is set' do
      person = Person.new(first_name: 'John', number: 1, manual_number: true)
      person.save.should be true

      person.number = 2
      person.save.should be true
      person.number.should be 2
    end

    it 'creates automatic number on update when flag is not set' do
      person = Person.new(first_name: 'John', number: 1, manual_number: true)
      person.save.should be true

      person.manual_number = false
      person.save.should be true
      person.number.should eq Person::AUTOMATIC_NUMBER_RANGE.first
    end

    it 'must be unique' do
      person1 = Person.new(first_name: 'John', number: 1, manual_number: true)
      person2 = Person.new(first_name: 'Jack', number: 1, manual_number: true)
      person1.should be_valid
      person2.should be_valid
      person1.save.should be true
      person2.save.should be false
    end

    it 'fails when manual number is at beginning of invalid range' do
      person = Person.new(first_name: 'John', number: Person::AUTOMATIC_NUMBER_RANGE.first, manual_number: true)
      person.should_not be_valid
    end

    it 'fails when manual number is at end of invalid range' do
      person = Person.new(first_name: 'John', number: Person::AUTOMATIC_NUMBER_RANGE.last - 1, manual_number: true)
      person.should_not be_valid
    end

    it 'is valid when manual number is just after invalid range' do
      person = Person.new(first_name: 'John', number: Person::AUTOMATIC_NUMBER_RANGE.last, manual_number: true)
      person.should be_valid
    end

    context 'manual' do
      it 'handles "0" strings correctly' do
        person = Person.new(manual_number: '0')
        person.manual_number.should be_false
      end

      it 'handles "1" strings correctly' do
        person = Person.new(manual_number: '1')
        person.manual_number.should be_true
      end

      it 'handles 1 integer correctly' do
        person = Person.new(manual_number: 1)
        person.manual_number.should be_true
      end

      it 'handles 0 integer correctly' do
        person = Person.new(manual_number: 0)
        person.manual_number.should be_false
      end

      it 'handles nil correctly with manual number' do
        person = Person.new(number: 1)
        person.manual_number.should be_true
      end

      it 'handles nil correctly with automatic number' do
        person = Person.new(number: Person::AUTOMATIC_NUMBER_RANGE.first)
        person.manual_number.should be_false
      end

      it 'generates automatic number if manual is nil' do
        person = Person.new(first_name: 'John', number: Person::AUTOMATIC_NUMBER_RANGE.first + 10)
        person.save
        person.number.should eq Person::AUTOMATIC_NUMBER_RANGE.first
      end

      it 'keeps manual number if manual is nil' do
        person = Person.new(first_name: 'John', number: 1)
        person.save
        person.number.should eq 1
      end

      it 'generates automatic number if manual is nil and old number existed' do
        person = Person.new(first_name: 'John', number: 1)
        person.save
        person.number.should eq 1

        person.number = Person::AUTOMATIC_NUMBER_RANGE.first + 10
        person.manual_number = nil
        person.save
        person.number.should eq Person::AUTOMATIC_NUMBER_RANGE.first
      end

      it 'keeps automatic number if manual is nil and old number existed' do
        person = Person.new(first_name: 'John')
        person.save
        person.number.should eq Person::AUTOMATIC_NUMBER_RANGE.first

        person.number = Person::AUTOMATIC_NUMBER_RANGE.first + 10
        person.manual_number = nil
        person.save
        person.number.should eq Person::AUTOMATIC_NUMBER_RANGE.first
      end
    end
  end

  context 'updating addresses' do

    it 'sets blank address fields to main values' do
      person = create

      person.reload.correspondence_general_first_name.should eq 'John'
      person.reload.correspondence_general_last_name.should eq 'Lennon'
      person.correspondence_course_address.should eq 'Pennylane'
      person.billing_general_town.should eq 'Liverpool'
      person.billing_course_zip_code.should eq 9933
      person.billing_course_country.should eq 'England'
    end

    it 'sets same_as_main according to values of address fields' do
      person = create
      person.update!(correspondence_general_same_as_main: false,
                     correspondence_general_first_name: 'Working class hero')

      person.reload.full_name.should eq 'John Lennon'
      person.correspondence_general_first_name.should eq 'Working class hero'
      person.correspondence_general_same_as_main.should be_false
    end

    def create(attrs={})
      Person.create!(attrs.merge(first_name: 'John', last_name: 'Lennon', address: 'Pennylane', zip_code: '9933', town: 'Liverpool', country: 'England'))
    end
  end

end
