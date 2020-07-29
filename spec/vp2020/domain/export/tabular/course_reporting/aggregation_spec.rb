# encoding: utf-8

#  Copyright (c) 2020, insieme Schweiz. This file is part of
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
        create!(create_course(leistungskategorie, fachkonzept: 'sport_jugend'), 'freizeit_und_sport', values)
        create!(create_course(leistungskategorie, fachkonzept: 'sport_erwachsen'), 'freizeit_und_sport', values)
        create!(create_course(leistungskategorie, fachkonzept: 'freizeit_jugend'), 'freizeit_und_sport', values)
        create!(create_course(leistungskategorie, fachkonzept: 'freizeit_erwachsen'), 'freizeit_und_sport', values)
        create!(create_course(leistungskategorie, fachkonzept: 'autonomie_foerderung'), 'weiterbildung', values)
      end

      it 'contains correct headers' do
        expect(exporter(leistungskategorie).labels).to eq [
          '',
          'Freizeit Kinder & Jugendliche',
          'Freizeit Erwachsene & altersdurchmischt',
          'Sport Kinder & Jugendliche',
          'Sport Erwachsene & altersdurchmischt',
          'Förderung der Autonomie/Bildung',
          'Total'
        ]
      end

      it 'contains correct row headers, values and sums' do
        rows = [nil] + export(leistungskategorie)
        expect(rows[1]).to eq ['Anzahl Kurse',                                              1,    1,    1,     1,    1,    5]
        expect(rows[2]).to eq ['Anzahl Kurstage',                                           2.0,  2.0,  2.0,   2.0,  2.0,  10.0]
        expect(rows[3]).to eq ['Anzahl effektive TeilnehmerInnen',                          3,    3,    3,     3,    3,    15]
        expect(rows[4]).to eq ['davon Behinderte',                                          1,    1,    1,     1,    1,    5]
        expect(rows[5]).to eq ['davon Angehörige',                                          2,    2,    2,     2,    2,    10]
        expect(rows[6]).to eq ['davon nicht Bezugsberechtigte',                             0,    0,    0,     0,    0,    0]
        expect(rows[7]).to eq ['Absenztage',                                                1.5,  1.5,  1.5,   1.5,  1.5,  7.5]
        expect(rows[8]).to eq ['davon Absenztage Behinderte',                               0.5,  0.5,  0.5,   0.5,  0.5,  2.5]
        expect(rows[9]).to eq ['davon Absenztage Angehörige',                               1.0,  1.0,  1.0,   1.0,  1.0,  5.0]
        expect(rows[10]).to eq ['davon Absenztage nicht Bezugsberechtigte',                 0,    0,    0,     0.0,  0.0,  0.0]
        expect(rows[11]).to eq ['Effektive TeilnehmerInnentage',                            4.5,  4.5,  4.5,   4.5,  4.5,  22.5]
        expect(rows[12]).to eq ['davon TeilnehmerInnentage Behinderte',                     1.5,  1.5,  1.5,   1.5,  1.5,  7.5]
        expect(rows[13]).to eq ['davon TeilnehmerInnentage Angehörige',                     3.0,  3.0,  3.0,   3.0,  3.0,  15.0]
        expect(rows[14]).to eq ['davon TeilnehmerInnentage nicht Bezugsberechtigte',        0.0,  0.0,  0.0,   0.0,  0.0,  0.0]
        expect(rows[15]).to eq ['Anzahl Betreuungspersonal',                                10,   10,   10,    10,   10,   50]
        expect(rows[16]).to eq ['davon LeiterInnen',                                        1,    1,    1,     1,    1,    5]
        expect(rows[17]).to eq ['davon Fachpersonen hochqualifiziert',                      2,    2,    2,     2,    2,    10]
        expect(rows[18]).to eq ['davon Hilfspersonal ohne Honorar',                         3,    3,    3,     3,    3,    15]
        expect(rows[19]).to eq ['davon Hilfspersonal mit Honorar',                          4,    4,    4,     4,    4,    20]
        expect(rows[20]).to eq ['Anzahl Küchenpersonal',                                    5,    5,    5,     5,    5,    25]
        expect(rows[21]).to eq ['Gesamtaufwand direkte Kosten',                             60.0, 60.0, 60.0,  60.0, 60.0, 300.0]
        expect(rows[22]).to eq ['davon Honorare',                                           10.0, 10.0, 10.0,  10.0, 10.0, 50.0]
        expect(rows[23]).to eq ['davon Unterkunft/Raumaufwand',                             20.0, 20.0, 20.0,  20.0, 20.0, 100.0]
        expect(rows[24]).to eq ['davon übriger Aufwand inkl. Verpflegung',                  30.0, 30.0, 30.0,  30.0, 30.0, 150.0]

        expect(rows[25][0]).to eq 'Durchschnittliche direkte Kosten pro TeilnehmerInnentag'
        expect(rows[25][1..-1].collect(&:to_i)).to eq [                                     13,   13,   13,    13,   13,   13]
        expect(rows[26]).to eq ['Vollkosten',                                               70.0, 70.0, 70.0,  70.0, 70.0, 350.0]
        expect(rows[27][0]).to eq 'Durchschnittliche Vollkosten pro TeilnehmerInnentag'
        expect(rows[27][1..-1].collect(&:to_i)).to eq [                                     15,   15,   15,    15,   15,   15]
        expect(rows[28]).to eq ['Beiträge Teilnehmende',                                    10.0, 10.0, 10.0,  10.0, 10.0, 50.0]
        expect(rows[29]).to eq ['Betreuungschlüssel (Teilnehmende / Betreuende)',           0.1,  0.1,  0.1,   0.1,  0.1,  0.1]
        expect(rows[30]).to eq ['Anzahl Kurse mit spezieller Unterkunft',                   1,    1,    1,     1,    1,    5]
      end
    end
  end

  context 'sk' do
    before do
      2.times do
        values[:absenzen_behinderte] = 2 # sk allows only integers
        create!(create_course('sk', fachkonzept: 'freizeit_jugend'), 'freizeit_und_sport', values)
        create!(create_course('sk', fachkonzept: 'autonomie_foerderung'), 'weiterbildung', values)
      end
    end

    it 'contains correct headers' do
      expect(exporter('sk').labels).to eq [
        '',
        'Freizeit Kinder & Jugendliche',
        'Freizeit Erwachsene & altersdurchmischt',
        'Sport Kinder & Jugendliche',
        'Sport Erwachsene & altersdurchmischt',
        'Förderung der Autonomie/Bildung',
        'Total'
      ]
    end

    it 'contains correct row headers, values and sums' do
      rows = [nil] + export('sk')
      expect(rows[1]).to eq ['Anzahl Kurse',                                                 2,        0,        0,        0,        2,        4]
      expect(rows[2]).to eq ['Anzahl Kursstunden',                                           4.0.to_d, 0.0.to_d, 0.0.to_d, 0.0.to_d, 4.0.to_d, 8.0.to_d]
      expect(rows[3]).to eq ['Anzahl effektive TeilnehmerInnen',                             6,        0,        0,        0,        6,        12]
      expect(rows[4]).to eq ['davon Behinderte',                                             2,        0,        0,        0,        2,        4]
      expect(rows[5]).to eq ['davon Angehörige',                                             4,        0,        0,        0,        4,        8]
      expect(rows[6]).to eq ['davon nicht Bezugsberechtigte',                                0,        0,        0,        0,        0,        0]
      expect(rows[7]).to eq ['Absenzstunden',                                                6.00,     0.00,     0.00,     0.00,     6.00,     12.00]
      expect(rows[8]).to eq ['davon Absenzstunden Behinderte',                               4.00,     0.00,     0.00,     0.00,     4.00,     8.00]
      expect(rows[9]).to eq ['davon Absenzstunden Angehörige',                               2.00,     0.00,     0.00,     0.00,     2.00,     4.00]
      expect(rows[10]).to eq ['davon Absenzstunden nicht Bezugsberechtigte',                 0.00,     0.00,     0.00,     0.00,     0.00,     0.00]
      expect(rows[11]).to eq ['Effektive TeilnehmerInnenstunden',                            6.0,      0.0,      0.0,      0.0,      6.0,      12.00]
      expect(rows[12]).to eq ['davon TeilnehmerInnenstunden Behinderte',                     0.0,      0.0,      0.0,      0.0,      0.0,      0.00]
      expect(rows[13]).to eq ['davon TeilnehmerInnenstunden Angehörige',                     6.00,     0.00,     0.00,     0.00,     6.00,     12.00]
      expect(rows[14]).to eq ['davon TeilnehmerInnenstunden nicht Bezugsberechtigte',        0.00,     0.00,     0.00,     0.00,     0.00,     0.00]
      expect(rows[15]).to eq ['Anzahl Betreuungspersonal',                                   20,       0,        0,        0,        20,       40]
      expect(rows[16]).to eq ['davon LeiterInnen',                                           2,        0,        0,        0,        2,        4]
      expect(rows[17]).to eq ['davon Fachpersonen hochqualifiziert',                         4,        0,        0,        0,        4,        8]
      expect(rows[18]).to eq ['davon Hilfspersonal ohne Honorar',                            6,        0,        0,        0,        6,        12]
      expect(rows[19]).to eq ['davon Hilfspersonal mit Honorar',                             8,        0,        0,        0,        8,        16]
      expect(rows[20]).to eq ['Anzahl Küchenpersonal',                                       10,       0,        0,        0,        10,       20]
      expect(rows[21]).to eq ['Gesamtaufwand direkte Kosten',                                120.00,   0.00,     0.00,     0.00,     120.00,   240.00]
      expect(rows[22]).to eq ['davon Honorare',                                              20.00,    0.00,     0.00,     0.00,     20.00,    40.00]
      expect(rows[23]).to eq ['davon Unterkunft/Raumaufwand',                                40.00,    0.00,     0.00,     0.00,     40.00,    80.00]
      expect(rows[24]).to eq ['davon übriger Aufwand inkl. Verpflegung',                     60.00,    0.00,     0.00,     0.00,     60.00,    120.00]
      expect(rows[25][0]).to eq 'Durchschnittliche direkte Kosten pro TeilnehmerInnenstunde'
      expect(rows[25][1..-1].collect(&:to_i)).to eq [nil,                                    20,       0,        0,        0,        20,       20][1..-1]
      expect(rows[26]).to eq ['Vollkosten',                                                  140.00,   0.00,     0.00,     0.00,     140.00,   280.00]
      expect(rows[27][0]).to eq 'Durchschnittliche Vollkosten pro TeilnehmerInnenstunde'
      expect(rows[27][1..-1].collect(&:to_i)).to eq [nil,                                    23,       0,        0,        0,        23,       23][1..-1]
      expect(rows[28]).to eq ['Beiträge Teilnehmende',                                       20.00,    0.00,     0.00,     0.00,     20.00,    40.00]
      expect(rows[29]).to eq ['Betreuungschlüssel (Teilnehmende / Betreuende)',              0.10,     0.00,     0.00,     0.00,     0.10,     0.10]
      expect(rows[30]).to eq ['Anzahl Kurse mit spezieller Unterkunft',                      0,        0,        0,        0,        0,        0]
    end
  end

  context 'tp' do
    before do
      2.times do
        values[:absenzen_behinderte] = 2 # sk allows only integers
        create!(create_course('tp', fachkonzept: 'treffpunkt'), 'freizeit_und_sport', values)
        create!(create_course('tp', fachkonzept: 'treffpunkt'), 'weiterbildung', values)
      end
    end

    it 'contains correct headers' do
      expect(exporter('tp').labels).to eq ['', 'Total']
    end

    it 'contains correct row headers, values and sums' do
      rows = [nil] + export('tp')
      expect(rows[1]).to eq ['Anzahl Durchführungen',                                       4]
      expect(rows[2]).to eq ['Anzahl Kursstunden',                                          8.0.to_d]
      expect(rows[3]).to eq ['Anzahl effektive TeilnehmerInnen',                            12]
      expect(rows[4]).to eq ['davon Behinderte',                                            4]
      expect(rows[5]).to eq ['davon Angehörige',                                            8]
      expect(rows[6]).to eq ['davon nicht Bezugsberechtigte',                               0]
      expect(rows[7]).to eq ['Anzahl Betreuungsstunden',                                    320.00]
      expect(rows[8]).to eq ['Betreuungspersonen',                                          40]
      expect(rows[9]).to eq ['Gesamtaufwand direkte Kosten',                                240.00]
      expect(rows[10]).to eq ['davon Honorare',                                             40.00]
      expect(rows[11]).to eq ['davon Unterkunft/Raumaufwand',                               80.00]
      expect(rows[12]).to eq ['davon übriger Aufwand inkl. Verpflegung',                    120.00]
      expect(rows[13]).to eq ['Durchschnittliche direkte Kosten pro TeilnehmerInnenstunde', 20]
      expect(rows[14]).to eq ['Vollkosten',                                                 280.00]
      expect(rows[15][0]).to eq 'Durchschnittliche Vollkosten pro TeilnehmerInnenstunde'
      expect(rows[15][1..-1].collect(&:to_i)).to eq [nil,                                   23][1..-1]
      expect(rows[16]).to eq ['Beiträge Teilnehmende',                                      40.00]
      expect(rows[17]).to eq ['Betreuungschlüssel (Teilnehmende / Betreuende)',             0.10]
      expect(rows[18]).to eq ['Anzahl Kurse mit spezieller Unterkunft',                     4]
    end
  end

  def create_course(leistungskategorie = 'bk', group_list: [groups(:be)], year: 2020, fachkonzept: 'sport_jugend')
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
