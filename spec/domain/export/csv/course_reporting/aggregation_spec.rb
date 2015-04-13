# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'
require 'csv'

describe Export::Csv::CourseReporting::Aggregation do

  let(:values) do
    { kursdauer: 0.5,
      challenged_canton_count_attributes: { be: 1 },
      affiliated_canton_count_attributes: { be: 2 },
      teilnehmende_weitere: 3,
      absenzen_behinderte: 0.5, absenzen_angehoerige: 1, absenzen_weitere: 1.5,
      leiterinnen: 1, fachpersonen: 2, hilfspersonal_ohne_honorar: 3, hilfspersonal_mit_honorar: 4, kuechenpersonal: 5,
      honorare_inkl_sozialversicherung: 10, unterkunft: 20, uebriges: 30,
      beitraege_teilnehmende: 10, spezielle_unterkunft: true,
      gemeinkostenanteil: 10,
    }
  end

  def export(leistungskategorie)
    exporter = described_class.new(new_aggregration(leistungskategorie: leistungskategorie))
    [].tap { |csv| exporter.to_csv(csv) }
  end

  context 'blockkurs' do
    before do
      create!(create_course('bk'), 'freizeit_und_sport', values)
      create!(create_course('bk'), 'weiterbildung', values)
      create!(create_course('bk'), 'freizeit_und_sport', values).tap { |c| c.update_column(:inputkriterien, :b) }
      create!(create_course('bk'), 'weiterbildung', values).tap { |c| c.update_column(:inputkriterien, :c) }
    end

    it 'contains correct headers' do
      expect(export('bk')[0]).to eq ["",
        "Inputkategorie A Weiterbildung", "Inputkategorie A Freizeit und Sport", "Inputkategorie A Total",
        "Inputkategorie B Weiterbildung", "Inputkategorie B Freizeit und Sport", "Inputkategorie B Total",
        "Inputkategorie C Weiterbildung", "Inputkategorie C Freizeit und Sport", "Inputkategorie C Total",
        "Total"
      ]
    end

    it 'contains correct row headers, values and sums' do
      expect(export('bk')[1..-1]).to eq [
        ["Anzahl Kurse", "1", "1", "2", "", "1", "1", "1", "", "1", "4"],
        ["Anzahl Kurstage", "0.50", "0.50", "1.00", "", "0.50", "0.50", "0.50", "", "0.50", "2.00"],
        ["Anzahl effektive TeilnehmerInnen", "6", "6", "12", "0", "6", "6", "6", "0", "6", "24"],
        ["davon Behinderte", "1", "1", "2", "", "1", "1", "1", "", "1", "4"],
        ["davon Angehörige", "2", "2", "4", "", "2", "2", "2", "", "2", "8"],
        ["davon nicht Bezugsberechtigte", "3", "3", "6", "", "3", "3", "3", "", "3", "12"],
        ["Absenztage", "3.00", "3.00", "6.00", "0.00", "3.00", "3.00", "3.00", "0.00", "3.00", "12.00"],
        ["dav. Absenztage Behinderte", "0.50", "0.50", "1.00", "", "0.50", "0.50", "0.50", "", "0.50", "2.00"],
        ["dav. Absenztage Angehörige", "1.00", "1.00", "2.00", "", "1.00", "1.00", "1.00", "", "1.00", "4.00"],
        ["dav. Absenztage nicht Bezugsberechtigte", "1.50", "1.50", "3.00", "", "1.50", "1.50", "1.50", "", "1.50", "6.00"],
        ["Effektive TeilnehmerInnentage", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00"],
        ["dav. TeilnehmerInnentage Behinderte", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00"],
        ["dav. TeilnehmerInnentage Angehörige", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00"],
        ["dav. TeilnehmerInnentage nicht Bezugsberechtigte", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00"],
        ["Anzahl Betreuungspersonal", "10", "10", "20", "0", "10", "10", "10", "0", "10", "40"],
        ["davon LeiterInnen", "1", "1", "2", "", "1", "1", "1", "", "1", "4"],
        ["davon Fachpersonen hochqualifiziert", "2", "2", "4", "", "2", "2", "2", "", "2", "8"],
        ["davon Hilfspersonal ohne Honorar", "3", "3", "6", "", "3", "3", "3", "", "3", "12"],
        ["davon Hilfspersonal mit Honorar", "4", "4", "8", "", "4", "4", "4", "", "4", "16"],
        ["Anzahl Küchenpersonal", "5", "5", "10", "", "5", "5", "5", "", "5", "20"],
        ["Gesamtaufwand direkte Kosten", "60.00", "60.00", "120.00", "0.00", "60.00", "60.00", "60.00", "0.00", "60.00", "240.00"],
        ["davon Honorare", "10.00", "10.00", "20.00", "", "10.00", "10.00", "10.00", "", "10.00", "40.00"],
        ["davon Unterkunft/Raumaufwand", "20.00", "20.00", "40.00", "", "20.00", "20.00", "20.00", "", "20.00", "80.00"],
        ["davon übriger Aufwand inkl. Verpflegung", "30.00", "30.00", "60.00", "", "30.00", "30.00", "30.00", "", "30.00", "120.00"],
        ["Durchschnittliche direkte Kosten pro TeilnehmerInnentag", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0"],
        ["Vollkosten", "70.00", "70.00", "140.00", "0.00", "70.00", "70.00", "70.00", "0.00", "70.00", "280.00"],
        ["durchschnittliche Vollkosten pro TeilnehmerInnentag", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0"],
        ["Beiträge Teilnehmende", "10.00", "10.00", "20.00", "", "10.00", "10.00", "10.00", "", "10.00", "40.00"],
        ["Betreuungschlüssel (Teilnehmende / Betreuende)", "0.10", "0.10", "0.20", "0", "0.10", "0.10", "0.10", "0", "0.10", "0.40"],
        ["Anzahl Kurse mit spezieller Unterkunft", "1", "1", "2", "", "1", "1", "1", "", "1", "4"]
      ]
    end
  end

  context 'tageskurs' do
    before do
      2.times do
        create!(create_course('tk'), 'freizeit_und_sport', values)
        create!(create_course('tk'), 'weiterbildung', values)
      end
    end

    it "contains correct headers" do
      expect(export('tk')[0]).to eq ["", "Weiterbildung", "Freizeit und Sport", "Total"]
    end

    it 'contains correct row headers, values and sums' do
      expect(export('tk')[1..-1]).to eq [
          ["Anzahl Kurse", "2", "2", "4"],
          ["Anzahl Kursstunden", "1.00", "1.00", "2.00"],
          ["Anzahl effektive TeilnehmerInnen", "12", "12", "24"],
          ["davon Behinderte", "2", "2", "4"],
          ["davon Angehörige", "4", "4", "8"],
          ["davon nicht Bezugsberechtigte", "6", "6", "12"],
          ["Absenzstunden", "6.00", "6.00", "12.00"],
          ["dav. Absenzstunden Behinderte", "1.00", "1.00", "2.00"],
          ["dav. Absenzstunden Angehörige", "2.00", "2.00", "4.00"],
          ["dav. Absenzstunden nicht Bezugsberechtigte", "3.00", "3.00", "6.00"],
          ["Effektive TeilnehmerInnenstunden", "6.00", "6.00", "12.00"],
          ["dav. TeilnehmerInnenstunden Behinderte", "1.00", "1.00", "2.00"],
          ["dav. TeilnehmerInnenstunden Angehörige", "2.00", "2.00", "4.00"],
          ["dav. TeilnehmerInnenstunden nicht Bezugsberechtigte", "3.00", "3.00", "6.00"],
          ["Anzahl Betreuungspersonal", "20", "20", "40"],
          ["davon LeiterInnen", "2", "2", "4"],
          ["davon Fachpersonen hochqualifiziert", "4", "4", "8"],
          ["davon Hilfspersonal ohne Honorar", "6", "6", "12"],
          ["davon Hilfspersonal mit Honorar", "8", "8", "16"],
          ["Anzahl Küchenpersonal", "10", "10", "20"],
          ["Gesamtaufwand direkte Kosten", "120.00", "120.00", "240.00"],
          ["davon Honorare", "20.00", "20.00", "40.00"],
          ["davon Unterkunft/Raumaufwand", "40.00", "40.00", "80.00"],
          ["davon übriger Aufwand inkl. Verpflegung", "60.00", "60.00", "120.00"],
          ["Durchschnittliche direkte Kosten pro TeilnehmerInnenstunde", "20.00", "20.00", "40.00"],
          ["Vollkosten", "140.00", "140.00", "280.00"],
          ["durchschnittliche Vollkosten pro TeilnehmerInnenstunde", "23.33", "23.33", "46.67"],
          ["Beiträge Teilnehmende", "20.00", "20.00", "40.00"],
          ["Betreuungschlüssel (Teilnehmende / Betreuende)", "0.10", "0.10", "0.20"],
          ["Anzahl Kurse mit spezieller Unterkunft", "2", "2", "4"]]
    end
  end

  def create_course(leistungskategorie = 'bk', group_list = [groups(:be)], year = 2014)
    Event::Course.create!(groups: group_list,
                          name: 'test',
                          leistungskategorie: leistungskategorie,
                          dates_attributes: [{ start_at: DateTime.new(year, 04, 15, 12, 00) }])
  end

  def create!(event, kursart = 'freizeit_und_sport', attrs = {})
    record = Event::CourseRecord.create!(event: event, kursart: kursart)
    record.update_attributes(attrs) # dont get set when used in create
    record
  end

  def new_aggregration(attrs = {})
    defaults = { group_id: groups(:be).id, year: 2014, leistungskategorie: 'bk', zugeteilte_kategorie: [1,2,3], subventioniert: [true, false] }
    CourseReporting::Aggregation.new(*defaults.merge(attrs).values)
  end
end
