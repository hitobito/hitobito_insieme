#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"
require "csv"

describe Export::Tabular::People::ParticipationsFull do
  let(:person) { people(:top_leader) }
  let(:participation) { event_participations(:top_leader) }
  let(:list) { Event::Participation.where(id: participation) }
  let(:people_list) { Export::Tabular::People::ParticipationsFull.new(list) }
  let(:labels) { people_list.attribute_labels }

  before do
    role_person = Fabricate(:person, {number: "123"})
    Fabricate(Group::Aktivmitglieder::Aktivmitglied.sti_name.to_sym,
      group: groups(:aktiv),
      person: role_person)
    person.reference_person_number = "123"
    person.save!
  end

  context "disabled_person_reference" do
    before do
      person.disabled_person_reference = true
      person.disabled_person_first_name = "George"
      person.disabled_person_last_name = "Harrison"
      person.disabled_person_address = "Abbey Road 3"
      person.disabled_person_zip_code = 1234
      person.disabled_person_town = "London"
      person.disabled_person_birthday = "25.02.1943"
      person.save!
    end

    context "labels" do
      it "should export disabled person fields" do
        expect(labels[:disabled_person_first_name]).to eq \
          "Vorname Zugehörige Person mit Behinderung"
        expect(labels[:disabled_person_last_name]).to eq \
          "Nachname Zugehörige Person mit Behinderung"
        expect(labels[:disabled_person_address]).to eq \
          "Adresse Zugehörige Person mit Behinderung"
        expect(labels[:disabled_person_zip_code]).to eq \
          "PLZ Zugehörige Person mit Behinderung"
        expect(labels[:disabled_person_town]).to eq \
          "Ort Zugehörige Person mit Behinderung"
        expect(labels[:disabled_person_birthday]).to eq \
          "Geburtstag Zugehörige Person mit Behinderung"
      end
    end

    context "values" do
      let(:data) { Export::Tabular::People::ParticipationsFull.csv(Event::Participation.where(id: participation.id)) }
      let(:csv) { CSV.parse(data, headers: true, col_sep: Settings.csv.separator) }

      it "should export disabled person fields" do
        expect(csv[0]["Vorname Zugehörige Person mit Behinderung"]).to eq "George"
        expect(csv[0]["Nachname Zugehörige Person mit Behinderung"]).to eq "Harrison"
        expect(csv[0]["Adresse Zugehörige Person mit Behinderung"]).to eq "Abbey Road 3"
        expect(csv[0]["PLZ Zugehörige Person mit Behinderung"]).to eq "1234"
        expect(csv[0]["Ort Zugehörige Person mit Behinderung"]).to eq "London"
        expect(csv[0]["Geburtstag Zugehörige Person mit Behinderung"]).to eq "25.02.1943"
      end
    end
  end
end
