# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'
describe Export::Csv::Events::DetailList do

  let(:courses) { double('courses', map: [], first: nil) }
  let(:list)  { Export::Csv::Events::DetailList.new(courses) }

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
                 :spezielle_unterkunft, :anzahl_kurse, 
                 # additional course record attributes
                 :kursdauer,
                 ## effektiv teilnehmende
                 :teilnehmende_behinderte, :teilnehmende_mehrfachbehinderte,
                 :teilnehmende_angehoerige, :teilnehmende_weitere,
                 ## absenztage
                 :absenzen_behinderte, :absenzen_angehoerige, :absenzen_weitere,
                 ## total teilnehmerinnentage
                 :tage_behinderte, :tage_angehoerige, :tage_weitere,
                 ## betreuerinnen
                 :leiterinnen, :fachpersonen,
                 :hilfspersonal_mit_honorar, :hilfspersonal_ohne_honorar,
                 ## personal ohne betreuungsfunktion
                 :kuechenpersonal,
                 ## direkter aufwand
                 :honorare_inkl_sozialversicherung, :unterkunft, :uebriges,
                 :direkter_aufwand,
                 # ertrag
                 :beitraege_teilnehmende, 
                 # auswertungen
                 :gemeinkostenanteil, :total_vollkosten,
                 :total_tage_teilnehmende, :vollkosten_pro_le,
                 :zugeteilte_kategorie]
    end

    its(:labels) do
      should == ['Name', 'Organisatoren', 'Kursnummer', 'Beschreibung', 'Status', 'Ort / Adresse',
                 'Datum 1 Beschreibung', 'Datum 1 Ort', 'Datum 1 Zeitraum',
                 'Datum 2 Beschreibung', 'Datum 2 Ort', 'Datum 2 Zeitraum',
                 'Datum 3 Beschreibung', 'Datum 3 Ort', 'Datum 3 Zeitraum',
                 'Kontaktperson Name', 'Kontaktperson Adresse', 'Kontaktperson PLZ',
                 'Kontaktperson Ort', 'Kontaktperson Haupt-E-Mail', 'Kontaktperson Telefonnummern',
                 'Hauptleitung Name', 'Hauptleitung Adresse', 'Hauptleitung PLZ', 'Hauptleitung Ort',
                 'Hauptleitung Haupt-E-Mail', 'Hauptleitung Telefonnummern',
                 'Motto', 'Kosten', 'Anmeldebeginn', 'Anmeldeschluss', 'Maximale Teilnehmerzahl',
                 'Externe Anmeldungen', 'Priorisierung',
                 'Anzahl BetreuerInnen', 'Anzahl Teilnehmende', 'Anzahl Anmeldungen',
                 'Leistungskategorie', 'Reporting im Jahr', 'Subventioniert', 'Inputkriterien',
                 'Kursart', 'Spezielle Unterkunft', 'Anzahl Kurse',
                 # additional course record attributes
                 'Kursdauer', 
                 ## effektiv teilnehmende
                 'Effektiv Teilnehmende Behinderte', 'Effektiv Teilnehmende Mehrfachbehinderte', 'Effektiv Teilnehmende Angehörige',
                 'Effektiv Teilnehmende Weitere, nicht Beitragsberechtigt',
                 ## absenztage
                 'Absenzen Behinderte', 'Absenzen Angehörige', 'Absenzen Weitere, nicht Beitragsberechtigt',
                 ## total teilnehmerinnentage
                 'Total TeilnehmerInnentage Behinderte', 'Total TeilnehmerInnentage Angehörige', 'Total TeilnehmerInnentage Weitere, nicht Beitragsberechtigt',
                 ## betreuerinnen
                 'LeiterInnen', 'Fachpersonen hochqualifiziert', 'Hilfspersonal mit Honorar',
                 'Hilfspersonal ohne Honorar', 
                 ## personal ohne betreuungsfunktion
                 'Küchenpersonal', 
                 ## direkter aufwand
                 'Honorare inkl. Sozialversicherung', 'Unterkunft / Raumaufwand', 'Übriges inkl. Verpflegung',
                 'Direkter Aufwand',
                 ## ertrag
                 'Beiträge TN',
                 # auswertungen
                 'Gemeinkostenanteil', 'Total Vollkosten', 'Anzahl tatsächliche LE',
                 'Vollkosten pro LE', 'Zugeteilte Kategorie']
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
                                  kursart: 'freizeit_und_sport', spezielle_unterkunft: true,
                                  kursdauer: 47,
                                  teilnehmende_behinderte: 33, teilnehmende_mehrfachbehinderte: 22,
                                  teilnehmende_angehoerige: 12, teilnehmende_weitere: 11,
                                  absenzen_behinderte: 3, absenzen_angehoerige: 1, absenzen_weitere: 2,
                                  tage_behinderte: 34, tage_angehoerige: 13,
                                  tage_weitere: 42,
                                  leiterinnen: 2, fachpersonen: 3, hilfspersonal_mit_honorar: 4, hilfspersonal_ohne_honorar: 5,
                                  kuechenpersonal: 1, 
                                  honorare_inkl_sozialversicherung: 500,
                                  unterkunft: 444, uebriges: 222, direkter_aufwand: 55,
                                  beitraege_teilnehmende: 33,
                                  gemeinkostenanteil: 56, zugeteilte_kategorie: 3
                                 )
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
        expect(row.count).to eq(70)
        expect(row[44..-1]).to eq [
                 # additional course record attributes
                 'Kursdauer', 
                 ## effektiv teilnehmende
                 'Effektiv Teilnehmende Behinderte', 'Effektiv Teilnehmende Mehrfachbehinderte', 'Effektiv Teilnehmende Angehörige',
                 'Effektiv Teilnehmende Weitere, nicht Beitragsberechtigt',
                 ## absenztage
                 'Absenzen Behinderte', 'Absenzen Angehörige', 'Absenzen Weitere, nicht Beitragsberechtigt',
                 ## total teilnehmerinnentage
                 'Total TeilnehmerInnentage Behinderte', 'Total TeilnehmerInnentage Angehörige', 'Total TeilnehmerInnentage Weitere, nicht Beitragsberechtigt',
                 ## betreuerinnen
                 'LeiterInnen', 'Fachpersonen hochqualifiziert', 'Hilfspersonal mit Honorar',
                 'Hilfspersonal ohne Honorar', 
                 ## personal ohne betreuungsfunktion
                 'Küchenpersonal', 
                 ## direkter aufwand
                 'Honorare inkl. Sozialversicherung', 'Unterkunft / Raumaufwand', 'Übriges inkl. Verpflegung',
                 'Direkter Aufwand',
                 ## ertrag
                 'Beiträge TN',
                 # auswertungen
                 'Gemeinkostenanteil', 'Total Vollkosten', 'Anzahl tatsächliche LE',
                 'Vollkosten pro LE', 'Zugeteilte Kategorie']
      end
    end

    context 'second row (course with record)' do
      let(:row) { csv[1].split(';') }
      it 'should contain the additional course and record fields' do
        expect(row[27..-1]).to eq ['All for one', '1000', '2000-01-01', '2000-02-01', '10',
                                   'nein', 'nein', '1', '2', '3', 'Blockkurs', '2012', 'ja', 'a',
                                   'Freizeit und Sport', 'ja', '1',
                                   '47.0',
                                   '33', '22', '12', '11', 
                                   '3.0', '1.0', '2.0', 
                                   '34.0', '13.0', '42.0',
                                   '2', '3', '4', '5',
                                   '1',
                                   '500.0', '444.0', '222.0', '55.0', '33.0', '56.0', '111.0', '89.0', '1.247191011235955056', '3' ]
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
