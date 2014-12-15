# encoding: utf-8

#  Copyright (c) 2014, insime Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'
describe Import::PersonImporter do

  before do
    parser.parse
    Person.stamper = user
  end

  let(:parser)        { Import::CsvParser.new([header, row].join("\n")) }
  let(:data)          { parser.map_data(mapping) }
  let(:user)          { people(:regio_leader) }
  let(:foreign_group) { groups(:chaeib) }
  let(:header)        { "Vorname,Nachname,Geburtsdatum,Nummer,Stadt" }
  let(:row)           { "John,Lennon,9.10.1940,#{number},Liverpool" }
  let(:number)        { 123 }

  let(:importer)  do
    Import::PersonImporter.new(data, groups(:aktiv), Group::Aktivmitglieder::Aktivmitglied)
  end

  let(:import_person) { importer.people.first }
  let(:person)        { import_person.person }


  context 'no number mapped' do
    let(:mapping) do
      { Vorname: 'first_name',
        Nachname: 'last_name',
        Geburtsdatum: 'birthday',
        Stadt: 'town' }
    end

    it 'keeps number of matching person' do
      existing = Person.create!(first_name: 'John', last_name: 'Lennon', number: 2, manual_number: true)

      person.should eq existing
      person.number.should eq 2
      import_person.should be_valid

      expect { importer.import }.not_to change { Person.count }
      existing.reload.number.should eq 2
      existing.first_name.should eq 'John'
      existing.town.should eq 'Liverpool'
    end

    it 'generates number for new person' do
      person.number.should eq Person::AUTOMATIC_NUMBER_RANGE.first
      person.should be_new_record
      import_person.should be_valid

      expect { importer.import }.to change { Person.count }.by(1)
    end
  end

  context 'number mapped' do
    let(:mapping) do
      { Vorname: 'first_name',
        Nachname: 'last_name',
        Geburtsdatum: 'birthday',
        Nummer: 'number',
        Stadt: 'town' }
    end

    context 'and given' do
      context 'automatic' do
        let(:number) { Person::AUTOMATIC_NUMBER_RANGE.first }

        it 'uses person with same automatic number from db' do
          existing = Person.create!(first_name: 'Hans', last_name: 'Lehmann')
          existing.number.should eq number

          person.should eq existing
          person.number.should eq number
          import_person.should be_valid

          expect { importer.import }.not_to change { Person.count }
          existing.reload.number.should eq number
          existing.first_name.should eq 'Hans'
          existing.town.should eq 'Liverpool'
        end

        it 'fails to create new person' do
          import_person.person.errors.should_not be_empty
          person.should be_new_record

          expect { importer.import }.not_to change { Person.count }
        end
      end

      context 'manual' do

        it 'uses person with same manual number from db' do
          existing = Person.create!(first_name: 'Hans', last_name: 'Lehmann', number: number, manual_number: true)

          person.should eq existing
          person.number.should eq number
          import_person.should be_valid

          expect { importer.import }.not_to change { Person.count }
          existing.reload.number.should eq number
          existing.first_name.should eq 'Hans'
          existing.town.should eq 'Liverpool'
        end

        it 'fails if person with other number matches' do
          existing = Person.create!(first_name: 'John', last_name: 'Lennon', number: 456, manual_number: true)

          person.should eq existing
          import_person.person.errors.should_not be_empty

          expect { importer.import }.not_to change { Person.count }
          existing.reload.number.should eq 456
          existing.town.should be_nil
        end

        it 'creates person if no other is found' do
          person.number.should eq 123
          import_person.should be_valid
          person.should be_new_record
          expect { importer.import }.to change { Person.count }.by(1)
        end

      end

    end

    context 'and not given' do
      let(:number) { '' }

      it 'keeps number of matching person' do
        existing = Person.create!(first_name: 'John', last_name: 'Lennon', number: 2, manual_number: true)

        person.should eq existing
        person.number.should eq 2
        import_person.should be_valid

        expect { importer.import }.not_to change { Person.count }
        existing.reload.number.should eq 2
        existing.first_name.should eq 'John'
        existing.town.should eq 'Liverpool'
      end

      it 'generates number when creating person' do
        person.number.should eq Person::AUTOMATIC_NUMBER_RANGE.first
        person.should be_new_record
        import_person.should be_valid

        expect { importer.import }.to change { Person.count }.by(1)
      end

    end
  end

end
