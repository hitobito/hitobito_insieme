# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Vp2020::Export::Tabular::CourseReporting::Aggregation do

  let(:values) do
    {
      kursdauer: 2,
      challenged_canton_count_attributes: { be: 1 },
      affiliated_canton_count_attributes: { be: 2 },
      teilnehmende_weitere: nil,
      absenzen_behinderte: 0.5,
      absenzen_angehoerige: 1,
      absenzen_weitere: nil,
      leiterinnen: 1,
      fachpersonen: 2,
      hilfspersonal_ohne_honorar: 3,
      hilfspersonal_mit_honorar: 4,
      kuechenpersonal: 5,
      honorare_inkl_sozialversicherung: 10,
      unterkunft: 20,
      uebriges: 30,
      beitraege_teilnehmende: 10,
      spezielle_unterkunft: true,
      gemeinkostenanteil: 10
    }
  end

  let(:year) { 2020 }

  def export(leistungskategorie)
    exporter(leistungskategorie).data_rows.to_a
  end

  def exporter(leistungskategorie)
    described_class.new(new_aggregration(leistungskategorie: leistungskategorie))
  end

  %w(bk tk).each do |leistungskategorie|
    context leistungskategorie do
      before do
        create!(create_course(leistungskategorie), 'freizeit_und_sport', values)
        create!(create_course(leistungskategorie), 'weiterbildung', values)
        create!(create_course(leistungskategorie, [groups(:be)], 2020, 'sport_erwachsen'), 'freizeit_und_sport', values)
        create!(create_course(leistungskategorie, [groups(:be)], 2020, 'freizeit_jugend'), 'freizeit_und_sport', values)
        create!(create_course(leistungskategorie, [groups(:be)], 2020, 'freizeit_erwachsen'), 'freizeit_und_sport', values)
        create!(create_course(leistungskategorie, [groups(:be)], 2020, 'autonomie_foerderung'), 'weiterbildung', values)
      end

      it 'contains correct headers' do
        expect(exporter(leistungskategorie).labels).to eq [
          '',
          'Freizeit Kinder & Jugendliche: Weiterbildung', 'Freizeit Kinder & Jugendliche: Freizeit und Sport', 'Freizeit Kinder & Jugendliche: Total',
          'Freizeit Erwachsene & altersdurchmischt: Weiterbildung', 'Freizeit Erwachsene & altersdurchmischt: Freizeit und Sport', 'Freizeit Erwachsene & altersdurchmischt: Total',
          'Sport Kinder & Jugendliche: Weiterbildung', 'Sport Kinder & Jugendliche: Freizeit und Sport', 'Sport Kinder & Jugendliche: Total',
          'Sport Erwachsene & altersdurchmischt: Weiterbildung', 'Sport Erwachsene & altersdurchmischt: Freizeit und Sport', 'Sport Erwachsene & altersdurchmischt: Total',
          'Förderung der Autonomie/Bildung: Weiterbildung', 'Förderung der Autonomie/Bildung: Freizeit und Sport', 'Förderung der Autonomie/Bildung: Total',
          'Total'
        ]
      end

      it 'contains correct row headers, values and sums' do
        rows = [nil] + export(leistungskategorie)
        expect(rows[1]).to eq ['Anzahl Kurse', nil, 1, 1, nil, 1, 1, 1, 1, 2, nil, 1, 1, 1, nil, 1, 6]
        expect(rows[2]).to eq ['Anzahl Kurstage', nil, 2.0, 2.0, nil, 2.0, 2.0, 2.0, 2.0, 4.0, nil, 2.0, 2.0, 2.0, nil, 2.0, 12.0]
        expect(rows[3]).to eq ['Anzahl effektive TeilnehmerInnen', 0, 3, 3, 0, 3, 3, 3, 3, 6, 0, 3, 3, 3, 0, 3, 18]
        expect(rows[4]).to eq ['davon Behinderte', nil, 1, 1, nil, 1, 1, 1, 1, 2, nil, 1, 1, 1, nil, 1, 6]
        expect(rows[5]).to eq ['davon Angehörige', nil, 2, 2, nil, 2, 2, 2, 2, 4, nil, 2, 2, 2, nil, 2, 12]
        expect(rows[6]).to eq ['davon nicht Bezugsberechtigte', nil, nil, 0, nil, nil, 0, nil, nil, 0, nil, nil, 0, nil, nil, 0, 0]
        expect(rows[7]).to eq ['Absenztage', 0.0, 1.5, 1.5, 0.0, 1.5, 1.5, 1.5, 1.5, 3.0, 0.0, 1.5, 1.5, 1.5, 0.0, 1.5, 9.0]
        expect(rows[8]).to eq ['davon Absenztage Behinderte', nil, 0.5, 0.5, nil, 0.5, 0.5, 0.5, 0.5, 1.0, nil, 0.5, 0.5, 0.5, nil, 0.5, 3.0]
        expect(rows[9]).to eq ['davon Absenztage Angehörige', nil, 1.0, 1.0, nil, 1.0, 1.0, 1.0, 1.0, 2.0, nil, 1.0, 1.0, 1.0, nil, 1.0, 6.0]
        expect(rows[10]).to eq ['davon Absenztage nicht Bezugsberechtigte', nil, nil, 0.0, nil, nil, 0.0, nil, nil, 0.0, nil, nil, 0.0, nil, nil, 0.0, 0.0]
        expect(rows[11]).to eq ['Effektive TeilnehmerInnentage', 0.0, 4.5, 4.5, 0.0, 4.5, 4.5, 4.5, 4.5, 9.0, 0.0, 4.5, 4.5, 4.5, 0.0, 4.5, 27.0]
        expect(rows[12]).to eq ['davon TeilnehmerInnentage Behinderte', nil, 1.5, 1.5, nil, 1.5, 1.5, 1.5, 1.5, 3.0, nil, 1.5, 1.5, 1.5, nil, 1.5, 9.0]
        expect(rows[13]).to eq ['davon TeilnehmerInnentage Angehörige', nil, 3.0, 3.0, nil, 3.0, 3.0, 3.0, 3.0, 6.0, nil, 3.0, 3.0, 3.0, nil, 3.0, 18.0]
        expect(rows[14]).to eq ['davon TeilnehmerInnentage nicht Bezugsberechtigte', nil, 0.0, 0.0, nil, 0.0, 0.0, 0.0, 0.0, 0.0, nil, 0.0, 0.0, 0.0, nil, 0.0, 0.0]
        expect(rows[15]).to eq ['Anzahl Betreuungspersonal', 0, 10, 10, 0, 10, 10, 10, 10, 20, 0, 10, 10, 10, 0, 10, 60]
        expect(rows[16]).to eq ['davon LeiterInnen', nil, 1, 1, nil, 1, 1, 1, 1, 2, nil, 1, 1, 1, nil, 1, 6]
        expect(rows[17]).to eq ['davon Fachpersonen hochqualifiziert', nil, 2, 2, nil, 2, 2, 2, 2, 4, nil, 2, 2, 2, nil, 2, 12]
        expect(rows[18]).to eq ['davon Hilfspersonal ohne Honorar', nil, 3, 3, nil, 3, 3, 3, 3, 6, nil, 3, 3, 3, nil, 3, 18]
        expect(rows[19]).to eq ['davon Hilfspersonal mit Honorar', nil, 4, 4, nil, 4, 4, 4, 4, 8, nil, 4, 4, 4, nil, 4, 24]
        expect(rows[20]).to eq ['Anzahl Küchenpersonal', nil, 5, 5, nil, 5, 5, 5, 5, 10, nil, 5, 5, 5, nil, 5, 30]
        expect(rows[21]).to eq ['Gesamtaufwand direkte Kosten', nil, 60.0, 60.0, nil, 60.0, 60.0, 60.0, 60.0, 120.0, nil, 60.0, 60.0, 60.0, nil, 60.0, 360.0]
        expect(rows[22]).to eq ['davon Honorare', nil, 10.0, 10.0, nil, 10.0, 10.0, 10.0, 10.0, 20.0, nil, 10.0, 10.0, 10.0, nil, 10.0, 60.0]
        expect(rows[23]).to eq ['davon Unterkunft/Raumaufwand', nil, 20.0, 20.0, nil, 20.0, 20.0, 20.0, 20.0, 40.0, nil, 20.0, 20.0, 20.0, nil, 20.0, 120.0]
        expect(rows[24]).to eq ['davon übriger Aufwand inkl. Verpflegung', nil, 30.0, 30.0, nil, 30.0, 30.0, 30.0, 30.0, 60.0, nil, 30.0, 30.0, 30.0, nil, 30.0, 180.0]
        expect(rows[25][0]).to eq 'Durchschnittliche direkte Kosten pro TeilnehmerInnentag'
        expect(rows[25][1..-1].collect(&:to_i)).to eq [0, 13, 13, 0, 13, 13, 13, 13, 13, 0, 13, 13, 13, 0, 13, 13]
        expect(rows[26]).to eq ['Vollkosten', 0.0, 70.0, 70.0, 0.0, 70.0, 70.0, 70.0, 70.0, 140.0, 0.0, 70.0, 70.0, 70.0, 0.0, 70.0, 420.0]
        expect(rows[27][0]).to eq 'Durchschnittliche Vollkosten pro TeilnehmerInnentag'
        expect(rows[27][1..-1].collect(&:to_i)).to eq [0, 15, 15, 0, 15, 15, 15, 15, 15, 0, 15, 15, 15, 0, 15, 15]
        expect(rows[28]).to eq ['Beiträge Teilnehmende', nil, 10.0, 10.0, nil, 10.0, 10.0, 10.0, 10.0, 20.0, nil, 10.0, 10.0, 10.0, nil, 10.0, 60.0]
        expect(rows[29]).to eq ['Betreuungschlüssel (Teilnehmende / Betreuende)', 0, 0.1, 0.1, 0, 0.1, 0.1, 0.1, 0.1, 0.1, 0, 0.1, 0.1, 0.1, 0, 0.1, 0.1]
        expect(rows[30]).to eq ['Anzahl Kurse mit spezieller Unterkunft', 0, 1, 1, 0, 1, 1, 1, 1, 2, 0, 1, 1, 1, 0, 1, 6]
      end
    end
  end

  context 'sk' do
    before do
      2.times do
        values[:absenzen_behinderte] = 2 # sk allows only integers
        create!(create_course('sk'), 'freizeit_und_sport', values)
        create!(create_course('sk'), 'weiterbildung', values)
      end
    end

    it 'contains correct headers' do
      expect(exporter('sk').labels).to eq ['', 'Weiterbildung', 'Freizeit und Sport', 'Total']
    end

    it 'contains correct row headers, values and sums' do
      rows = [nil] + export('sk')
      expect(rows[1]).to eq ['Anzahl Kurse', 2, 2, 4]
      expect(rows[2]).to eq ['Anzahl Kursstunden', 4.0.to_d, 4.0.to_d, 8.0.to_d]
      expect(rows[3]).to eq ['Anzahl effektive TeilnehmerInnen', 6, 6, 12]
      expect(rows[4]).to eq ['davon Behinderte', 2, 2, 4]
      expect(rows[5]).to eq ['davon Angehörige', 4, 4, 8]
      expect(rows[6]).to eq ['davon nicht Bezugsberechtigte', 0, 0, 0]
      expect(rows[7]).to eq ['Absenzstunden', 6.00, 6.00, 12.00]
      expect(rows[8]).to eq ['davon Absenzstunden Behinderte', 4.00, 4.00, 8.00]
      expect(rows[9]).to eq ['davon Absenzstunden Angehörige', 2.00, 2.00, 4.00]
      expect(rows[10]).to eq ['davon Absenzstunden nicht Bezugsberechtigte', 0.00, 0.00, 0.00]
      expect(rows[11]).to eq ['Effektive TeilnehmerInnenstunden', 6.0, 6.0, 12.00]
      expect(rows[12]).to eq ['davon TeilnehmerInnenstunden Behinderte', 0.0, 0.0, 0.00]
      expect(rows[13]).to eq ['davon TeilnehmerInnenstunden Angehörige', 6.00, 6.00, 12.00]
      expect(rows[14]).to eq ['davon TeilnehmerInnenstunden nicht Bezugsberechtigte', 0.00, 0.00, 0.00]
      expect(rows[15]).to eq ['Anzahl Betreuungspersonal', 20, 20, 40]
      expect(rows[16]).to eq ['davon LeiterInnen', 2, 2, 4]
      expect(rows[17]).to eq ['davon Fachpersonen hochqualifiziert', 4, 4, 8]
      expect(rows[18]).to eq ['davon Hilfspersonal ohne Honorar', 6, 6, 12]
      expect(rows[19]).to eq ['davon Hilfspersonal mit Honorar', 8, 8, 16]
      expect(rows[20]).to eq ['Anzahl Küchenpersonal', 10, 10, 20]
      expect(rows[21]).to eq ['Gesamtaufwand direkte Kosten', 120.00, 120.00, 240.00]
      expect(rows[22]).to eq ['davon Honorare', 20.00, 20.00, 40.00]
      expect(rows[23]).to eq ['davon Unterkunft/Raumaufwand', 40.00, 40.00, 80.00]
      expect(rows[24]).to eq ['davon übriger Aufwand inkl. Verpflegung', 60.00, 60.00, 120.00]
      expect(rows[25][0]).to eq 'Durchschnittliche direkte Kosten pro TeilnehmerInnenstunde'
      expect(rows[25][1..-1].collect(&:to_i)).to eq [20, 20, 20]
      expect(rows[26]).to eq ['Vollkosten', 140.00, 140.00, 280.00]
      expect(rows[27][0]).to eq 'Durchschnittliche Vollkosten pro TeilnehmerInnenstunde'
      expect(rows[27][1..-1].collect(&:to_i)).to eq [23, 23, 23]
      expect(rows[28]).to eq ['Beiträge Teilnehmende', 20.00, 20.00, 40.00]
      expect(rows[29]).to eq ['Betreuungschlüssel (Teilnehmende / Betreuende)', 0.10, 0.10, 0.10]
      expect(rows[30]).to eq ['Anzahl Kurse mit spezieller Unterkunft', 0, 0, 0]
    end
  end

  def create_course(leistungskategorie = 'bk', group_list = [groups(:be)], year = 2020, fachkonzept = 'sport_jugend')
    Event::Course.create!(groups: group_list,
                          name: 'test',
                          leistungskategorie: leistungskategorie, fachkonzept: fachkonzept,
                          dates_attributes: [{ start_at: DateTime.new(year, 04, 15, 12, 00) }])
  end

  def create!(event, kursart = 'freizeit_und_sport', attrs = {})
    Event::CourseRecord.create!(attrs.merge(event: event, kursart: kursart))
  end

  def new_aggregration(attrs = {})
    defaults = { group_id: groups(:be).id,
                 year: year,
                 leistungskategorie: 'bk',
                 zugeteilte_kategorie: [1,2,3],
                 subventioniert: [true, false] }
    vp_class('CourseReporting::Aggregation').new(*defaults.merge(attrs).values)
  end
end
