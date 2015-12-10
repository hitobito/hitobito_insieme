# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'
describe Export::Csv::Events::List do

  let(:courses) { double('courses', map: [], first: nil) }
  let(:list)  { Export::Csv::Events::List.new(courses) }

  context 'used labels' do
    subject { list }

    its(:attributes) do
      should == [:name, :group_names, :number, :description, :state, :location,
                 :date_0_label, :date_0_location, :date_0_duration,
                 :date_1_label, :date_1_location, :date_1_duration,
                 :date_2_label, :date_2_location, :date_2_duration,
                 :contact_name, :contact_address, :contact_zip_code, :contact_town,
                 :contact_email, :contact_phone_numbers,
                 :leader_name, :leader_address, :leader_zip_code, :leader_town,
                 :leader_email, :leader_phone_numbers,
                 :motto, :cost, :application_opening_at, :application_closing_at,
                 :maximum_participants, :external_applications, :priorization,
                 :teamer_count, :participant_count, :applicant_count,
                 :leistungskategorie, :year, :subventioniert, :inputkriterien, :kursart,
                 :spezielle_unterkunft, :anzahl_kurse]
    end

    its(:labels) do
      should == ['Name', 'Organisatoren', 'Kursnummer', 'Beschreibung', 'Status', 'Ort / Adresse',
                 'Datum 1 Bezeichnung', 'Datum 1 Ort', 'Datum 1 Zeitraum',
                 'Datum 2 Bezeichnung', 'Datum 2 Ort', 'Datum 2 Zeitraum',
                 'Datum 3 Bezeichnung', 'Datum 3 Ort', 'Datum 3 Zeitraum',
                 'Kontaktperson Name', 'Kontaktperson Adresse', 'Kontaktperson PLZ',
                 'Kontaktperson Ort', 'Kontaktperson Haupt-E-Mail', 'Kontaktperson Telefonnummern',
                 'Hauptleitung Name', 'Hauptleitung Adresse', 'Hauptleitung PLZ', 'Hauptleitung Ort',
                 'Hauptleitung Haupt-E-Mail', 'Hauptleitung Telefonnummern',
                 'Motto', 'Kosten', 'Anmeldebeginn', 'Anmeldeschluss', 'Maximale Teilnehmerzahl',
                 'Externe Anmeldungen', 'Priorisierung',
                 'Anzahl BetreuerInnen', 'Anzahl Teilnehmende', 'Anzahl Anmeldungen',
                 'Leistungskategorie', 'Reporting im Jahr', 'Subventioniert', 'Inputkriterien',
                 'Kursart', 'Spezielle Unterkunft', 'Anzahl Kurse']
    end
  end

  context 'to_csv' do
    let(:courses) { [course1, course2] }
    let(:course1) do
      Fabricate(:course, groups: [groups(:be)], motto: 'All for one', cost: 1000,
                    application_opening_at: '01.01.2000', application_closing_at: '01.02.2000',
                    maximum_participants: 10, external_applications: false, priorization: false,
                    leistungskategorie: 'bk')
    end
    let(:course2) { Fabricate(:course, groups: [groups(:be)], leistungskategorie: 'bk') }
    let(:csv) { Export::Csv::Generator.new(list).csv.split("\n") }

    before do
      course1.build_course_record(subventioniert: true, inputkriterien: 'a',
                                  kursart: 'freizeit_und_sport', spezielle_unterkunft: true)
      Fabricate(:event_participation, event: course1, active: true,
                roles: [Fabricate(:event_role, type: Event::Course::Role::LeaderBasic.sti_name)])
      Fabricate(:event_participation, event: course1, active: true,
                roles: [Fabricate(:event_role, type: Event::Course::Role::Challenged.sti_name)])
      Fabricate(:event_participation, event: course1, active: true,
                roles: [Fabricate(:event_role, type: Event::Course::Role::Challenged.sti_name)])
      Fabricate(:event_participation, event: course1, active: false,
                roles: [Fabricate(:event_role, type: Event::Course::Role::Challenged.sti_name)])
      course1.refresh_participant_counts!
    end

    context 'first row' do
      let(:row) { csv[0].split(';') }
      it 'should contain the additional course and record fields' do
        expect(row[27..-1]).to eq ['Motto', 'Kosten', 'Anmeldebeginn', 'Anmeldeschluss',
                                   'Maximale Teilnehmerzahl', 'Externe Anmeldungen',
                                   'Priorisierung', 'Anzahl BetreuerInnen', 'Anzahl Teilnehmende',
                                   'Anzahl Anmeldungen', 'Leistungskategorie',
                                   'Reporting im Jahr', 'Subventioniert',
                                   'Inputkriterien', 'Kursart', 'Spezielle Unterkunft',
                                   'Anzahl Kurse']
      end
    end

    context 'second row (course with record)' do
      let(:row) { csv[1].split(';') }
      it 'should contain the additional course and record fields' do
        expect(row[27..-1]).to eq ['All for one', '1000', '2000-01-01', '2000-02-01', '10',
                                   'nein', 'nein', '1', '2', '3', 'Blockkurs', '2012', 'ja', 'a',
                                   'Freizeit und Sport', 'ja', '1']
      end
    end

    context 'third row (course without record)' do
      let(:row) { csv[2].split(';') }
      it 'should contain the additional course and record fields' do
        expect(row[27..-1]).to eq ['', '', '', '', '', 'nein', 'ja', '0', '0', '0', 'Blockkurs']
      end
    end

  end

end
