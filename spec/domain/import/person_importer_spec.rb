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
    importer = Import::PersonImporter.new(data, groups(:aktiv), Group::Aktivmitglieder::Aktivmitglied)
    importer.user_ability = Ability.new(people(:top_leader))
    importer
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

      expect(person).to eq existing
      expect(person.number).to eq 2
      expect(import_person).to be_valid

      expect { importer.import }.not_to change { Person.count }
      expect(existing.reload.number).to eq 2
      expect(existing.first_name).to eq 'John'
      expect(existing.town).to eq 'Liverpool'
    end

    it 'generates number for new person' do
      expect(person.number).to eq Person::AUTOMATIC_NUMBER_RANGE.first
      expect(person).to be_new_record
      expect(import_person).to be_valid

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
          expect(existing.number).to eq number

          expect(person).to eq existing
          expect(person.number).to eq number
          expect(import_person).to be_valid

          expect { importer.import }.not_to change { Person.count }
          expect(existing.reload.number).to eq number
          expect(existing.first_name).to eq 'Hans'
          expect(existing.town).to eq 'Liverpool'
        end

        it 'fails to create new person' do
          expect(person.errors).not_to be_empty
          expect(person).to be_new_record

          expect { importer.import }.not_to change { Person.count }
        end
      end

      context 'manual' do

        it 'uses person with same manual number from db' do
          existing = Person.create!(first_name: 'Hans', last_name: 'Lehmann', number: number, manual_number: true)

          expect(person).to eq existing
          expect(person.number).to eq number
          expect(import_person).to be_valid

          expect { importer.import }.not_to change { Person.count }
          expect(existing.reload.number).to eq number
          expect(existing.first_name).to eq 'Hans'
          expect(existing.town).to eq 'Liverpool'
        end

        it 'fails if person with other number matches' do
          existing = Person.create!(first_name: 'John', last_name: 'Lennon', number: 456, manual_number: true)

          expect(person).to eq existing
          expect(import_person.person.errors).not_to be_empty

          expect { importer.import }.not_to change { Person.count }
          expect(existing.reload.number).to eq 456
          expect(existing.town).to be_nil
        end

        it 'creates person if no other is found' do
          expect(person.number).to eq 123
          expect(import_person).to be_valid
          expect(person).to be_new_record
          expect { importer.import }.to change { Person.count }.by(1)
        end

      end

    end

    context 'and not given' do
      let(:number) { '' }

      it 'keeps number of matching person' do
        existing = Person.create!(first_name: 'John', last_name: 'Lennon', number: 2, manual_number: true)

        expect(person).to eq existing
        expect(person.number).to eq 2
        expect(import_person).to be_valid

        expect { importer.import }.not_to change { Person.count }
        expect(existing.reload.number).to eq 2
        expect(existing.first_name).to eq 'John'
        expect(existing.town).to eq 'Liverpool'
      end

      it 'generates number when creating person' do
        expect(person.number).to eq Person::AUTOMATIC_NUMBER_RANGE.first
        expect(person).to be_new_record
        expect(import_person).to be_valid

        expect { importer.import }.to change { Person.count }.by(1)
      end

    end
  end

end
