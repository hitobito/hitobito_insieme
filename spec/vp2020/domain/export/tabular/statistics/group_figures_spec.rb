# frozen_string_literal: true

#  Copyright (c) 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Vp2020::Export::Tabular::Statistics::GroupFigures do

  let(:year) { 2020 }

  before do
    TimeRecord::EmployeeTime.create!(group: groups(:be),
                                     year: year,
                                     interviews: 10,
                                     employee_pensum_attributes: { paragraph_74: 0.25 })
    TimeRecord::EmployeeTime.create!(group: groups(:be), year: year - 1, newsletter: 11)
    TimeRecord::EmployeeTime.create!(group: groups(:fr),
                                     year: year,
                                     projekte: 12,
                                     employee_pensum_attributes: {
                                       paragraph_74: 1.6, not_paragraph_74: 0.4 })

    TimeRecord::VolunteerWithVerificationTime.create!(
      group: groups(:be), year: year, vermittlung_kontakte: 20)
    TimeRecord::VolunteerWithVerificationTime.create!(
      group: groups(:fr), year: year, referate: 21)

    TimeRecord::VolunteerWithoutVerificationTime.create!(
      group: groups(:be), year: year, total_lufeb_promoting: 30)

    CostAccountingRecord.create!(group: groups(:be), year: year, report: 'raumaufwand',
                                 raeumlichkeiten: 100)
    CostAccountingRecord.create!(group: groups(:be), year: year, report: 'honorare',
                                 aufwand_ertrag_fibu: 100, verwaltung: 10,
                                 beratung: 30)
    CostAccountingRecord.create!(group: groups(:be), year: year, report: 'leistungsertrag',
                                 aufwand_ertrag_fibu: 100, abgrenzung_fibu: 80,
                                 lufeb: 20)
    CostAccountingRecord.create!(group: groups(:be), year: year, report: 'direkte_spenden',
                                 aufwand_ertrag_fibu: 10, lufeb: 2, tageskurse: 8)
    CostAccountingRecord.create!(group: groups(:be), year: year, report: 'beitraege_iv',
                                 aufwand_ertrag_fibu: 100, abgrenzung_fibu: 80,
                                 lufeb: 20)

    CapitalSubstrate.create!(
      group: groups(:be), year: year, organization_capital: 500_000, fund_building: 25_000)
    CapitalSubstrate.create!(
      group: groups(:fr), year: year, organization_capital: 250_000, fund_building: 15_000)

    create_course(year, :be, 'bk', '1', kursdauer: 10, unterkunft: 500,
                  challenged_canton_count_attributes: { zh: 100 })
    create_course(year, :be, 'bk', '1', kursdauer: 11, gemeinkostenanteil: 600,
                  affiliated_canton_count_attributes: { zh: 101 })
    create_course(year, :be, 'bk', '2', kursdauer: 12, unterkunft: 800,
                  challenged_canton_count_attributes: { zh: 450 })
    create_course(year, :be, 'bk', '3', kursdauer: 13, teilnehmende_weitere: 650, uebriges: 200)
    create_course(year, :be, 'sk', '1', kursdauer: 14, unterkunft: 400,
                  honorare_inkl_sozialversicherung: 10,
                  challenged_canton_count_attributes: { zh: 102 })
    create_course(year, :fr, 'bk', '1', kursdauer: 15, unterkunft: 0,
                  challenged_canton_count_attributes: { zh: 103 })
    create_course(year, :fr, 'tk', '1', kursdauer: 16, teilnehmende_weitere: 104, unterkunft: 500)
    create_course(year, :fr, 'tk', '3', kursdauer: 17, uebriges: 600,
                  challenged_canton_count_attributes: { zh: 500 })

    # other year
    create_course(year - 1, :fr, 'bk', '1', kursdauer: 17, teilnehmende_weitere: 105)
  end

  let(:figures) { vp_class('Statistics::GroupFigures').new(year) }

  def export(figures)
    exporter = described_class.new(figures)
    exporter.data_rows.to_a
  end

  it 'contains correct headers' do
    labels = described_class.new(figures).labels
    expect(labels).to match_array [
      "Vollständiger Name",
      "Kanton",
      "VID",
      "BSV Nummer",

      "Blockkurse Anzahl Kurse Freizeit Kinder & Jugendliche",
      "Blockkurse Total Vollkosten Freizeit Kinder & Jugendliche)",
      "Blockkurse TN Tage Behinderte Freizeit Kinder & Jugendliche",
      "Blockkurse TN Tage Angehörige Freizeit Kinder & Jugendliche",
      "Blockkurse TN Tage nicht Bezugsberechtigte Freizeit Kinder & Jugendliche",
      "Blockkurse TN Tage Total Freizeit Kinder & Jugendliche",

      "Blockkurse Anzahl Kurse Freizeit Erwachsene & altersdurchmischt",
      "Blockkurse Total Vollkosten Freizeit Erwachsene & altersdurchmischt)",
      "Blockkurse TN Tage Behinderte Freizeit Erwachsene & altersdurchmischt",
      "Blockkurse TN Tage Angehörige Freizeit Erwachsene & altersdurchmischt",
      "Blockkurse TN Tage nicht Bezugsberechtigte Freizeit Erwachsene & altersdurchmischt",
      "Blockkurse TN Tage Total Freizeit Erwachsene & altersdurchmischt",

      "Blockkurse Anzahl Kurse Sport Kinder & Jugendliche",
      "Blockkurse Total Vollkosten Sport Kinder & Jugendliche)",
      "Blockkurse TN Tage Behinderte Sport Kinder & Jugendliche",
      "Blockkurse TN Tage Angehörige Sport Kinder & Jugendliche",
      "Blockkurse TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche",
      "Blockkurse TN Tage Total Sport Kinder & Jugendliche",

      "Blockkurse Anzahl Kurse Sport Erwachsene & altersdurchmischt",
      "Blockkurse Total Vollkosten Sport Erwachsene & altersdurchmischt)",
      "Blockkurse TN Tage Behinderte Sport Erwachsene & altersdurchmischt",
      "Blockkurse TN Tage Angehörige Sport Erwachsene & altersdurchmischt",
      "Blockkurse TN Tage nicht Bezugsberechtigte Sport Erwachsene & altersdurchmischt",
      "Blockkurse TN Tage Total Sport Erwachsene & altersdurchmischt",

      "Blockkurse Anzahl Kurse Förderung der Autonomie/Bildung",
      "Blockkurse Total Vollkosten Förderung der Autonomie/Bildung)",
      "Blockkurse TN Tage Behinderte Förderung der Autonomie/Bildung",
      "Blockkurse TN Tage Angehörige Förderung der Autonomie/Bildung",
      "Blockkurse TN Tage nicht Bezugsberechtigte Förderung der Autonomie/Bildung",
      "Blockkurse TN Tage Total Förderung der Autonomie/Bildung",

      "Tageskurse Anzahl Kurse Freizeit Kinder & Jugendliche",
      "Tageskurse Total Vollkosten Freizeit Kinder & Jugendliche)",
      "Tageskurse TN Tage Behinderte Freizeit Kinder & Jugendliche",
      "Tageskurse TN Tage Angehörige Freizeit Kinder & Jugendliche",
      "Tageskurse TN Tage nicht Bezugsberechtigte Freizeit Kinder & Jugendliche",
      "Tageskurse TN Tage Total Freizeit Kinder & Jugendliche",

      "Tageskurse Anzahl Kurse Freizeit Erwachsene & altersdurchmischt",
      "Tageskurse Total Vollkosten Freizeit Erwachsene & altersdurchmischt)",
      "Tageskurse TN Tage Behinderte Freizeit Erwachsene & altersdurchmischt",
      "Tageskurse TN Tage Angehörige Freizeit Erwachsene & altersdurchmischt",
      "Tageskurse TN Tage nicht Bezugsberechtigte Freizeit Erwachsene & altersdurchmischt",
      "Tageskurse TN Tage Total Freizeit Erwachsene & altersdurchmischt",

      "Tageskurse Anzahl Kurse Sport Kinder & Jugendliche",
      "Tageskurse Total Vollkosten Sport Kinder & Jugendliche)",
      "Tageskurse TN Tage Behinderte Sport Kinder & Jugendliche",
      "Tageskurse TN Tage Angehörige Sport Kinder & Jugendliche",
      "Tageskurse TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche",
      "Tageskurse TN Tage Total Sport Kinder & Jugendliche",

      "Tageskurse Anzahl Kurse Sport Erwachsene & altersdurchmischt",
      "Tageskurse Total Vollkosten Sport Erwachsene & altersdurchmischt)",
      "Tageskurse TN Tage Behinderte Sport Erwachsene & altersdurchmischt",
      "Tageskurse TN Tage Angehörige Sport Erwachsene & altersdurchmischt",
      "Tageskurse TN Tage nicht Bezugsberechtigte Sport Erwachsene & altersdurchmischt",
      "Tageskurse TN Tage Total Sport Erwachsene & altersdurchmischt",

      "Tageskurse Anzahl Kurse Förderung der Autonomie/Bildung",
      "Tageskurse Total Vollkosten Förderung der Autonomie/Bildung)",
      "Tageskurse TN Tage Behinderte Förderung der Autonomie/Bildung",
      "Tageskurse TN Tage Angehörige Förderung der Autonomie/Bildung",
      "Tageskurse TN Tage nicht Bezugsberechtigte Förderung der Autonomie/Bildung",
      "Tageskurse TN Tage Total Förderung der Autonomie/Bildung",

      "Semester-/Jahreskurse Anzahl Kurse Freizeit Kinder & Jugendliche",
      "Semester-/Jahreskurse Total Vollkosten Freizeit Kinder & Jugendliche)",
      "Semester-/Jahreskurse TN Tage Behinderte Freizeit Kinder & Jugendliche",
      "Semester-/Jahreskurse TN Tage Angehörige Freizeit Kinder & Jugendliche",
      "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Freizeit Kinder & Jugendliche",
      "Semester-/Jahreskurse TN Tage Total Freizeit Kinder & Jugendliche",

      "Semester-/Jahreskurse Anzahl Kurse Freizeit Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse Total Vollkosten Freizeit Erwachsene & altersdurchmischt)",
      "Semester-/Jahreskurse TN Tage Behinderte Freizeit Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse TN Tage Angehörige Freizeit Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Freizeit Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse TN Tage Total Freizeit Erwachsene & altersdurchmischt",

      "Semester-/Jahreskurse Anzahl Kurse Sport Kinder & Jugendliche",
      "Semester-/Jahreskurse Total Vollkosten Sport Kinder & Jugendliche)",
      "Semester-/Jahreskurse TN Tage Behinderte Sport Kinder & Jugendliche",
      "Semester-/Jahreskurse TN Tage Angehörige Sport Kinder & Jugendliche",
      "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche",
      "Semester-/Jahreskurse TN Tage Total Sport Kinder & Jugendliche",

      "Semester-/Jahreskurse Anzahl Kurse Sport Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse Total Vollkosten Sport Erwachsene & altersdurchmischt)",
      "Semester-/Jahreskurse TN Tage Behinderte Sport Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse TN Tage Angehörige Sport Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Sport Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse TN Tage Total Sport Erwachsene & altersdurchmischt",

      "Semester-/Jahreskurse Anzahl Kurse Förderung der Autonomie/Bildung",
      "Semester-/Jahreskurse Total Vollkosten Förderung der Autonomie/Bildung)",
      "Semester-/Jahreskurse TN Tage Behinderte Förderung der Autonomie/Bildung",
      "Semester-/Jahreskurse TN Tage Angehörige Förderung der Autonomie/Bildung",
      "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Förderung der Autonomie/Bildung",
      "Semester-/Jahreskurse TN Tage Total Förderung der Autonomie/Bildung",

      "Treffpunkte Anzahl Kurse Freizeit Kinder & Jugendliche",
      "Treffpunkte Total Vollkosten Freizeit Kinder & Jugendliche)",
      "Treffpunkte TN Tage Behinderte Freizeit Kinder & Jugendliche",
      "Treffpunkte TN Tage Angehörige Freizeit Kinder & Jugendliche",
      "Treffpunkte TN Tage nicht Bezugsberechtigte Freizeit Kinder & Jugendliche",
      "Treffpunkte TN Tage Total Freizeit Kinder & Jugendliche",

      "Treffpunkte Anzahl Kurse Freizeit Erwachsene & altersdurchmischt",
      "Treffpunkte Total Vollkosten Freizeit Erwachsene & altersdurchmischt)",
      "Treffpunkte TN Tage Behinderte Freizeit Erwachsene & altersdurchmischt",
      "Treffpunkte TN Tage Angehörige Freizeit Erwachsene & altersdurchmischt",
      "Treffpunkte TN Tage nicht Bezugsberechtigte Freizeit Erwachsene & altersdurchmischt",
      "Treffpunkte TN Tage Total Freizeit Erwachsene & altersdurchmischt",

      "Treffpunkte Anzahl Kurse Sport Kinder & Jugendliche",
      "Treffpunkte Total Vollkosten Sport Kinder & Jugendliche)",
      "Treffpunkte TN Tage Behinderte Sport Kinder & Jugendliche",
      "Treffpunkte TN Tage Angehörige Sport Kinder & Jugendliche",
      "Treffpunkte TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche",
      "Treffpunkte TN Tage Total Sport Kinder & Jugendliche",

      "Treffpunkte Anzahl Kurse Sport Erwachsene & altersdurchmischt",
      "Treffpunkte Total Vollkosten Sport Erwachsene & altersdurchmischt)",
      "Treffpunkte TN Tage Behinderte Sport Erwachsene & altersdurchmischt",
      "Treffpunkte TN Tage Angehörige Sport Erwachsene & altersdurchmischt",
      "Treffpunkte TN Tage nicht Bezugsberechtigte Sport Erwachsene & altersdurchmischt",
      "Treffpunkte TN Tage Total Sport Erwachsene & altersdurchmischt",

      "Treffpunkte Anzahl Kurse Förderung der Autonomie/Bildung",
      "Treffpunkte Total Vollkosten Förderung der Autonomie/Bildung)",
      "Treffpunkte TN Tage Behinderte Förderung der Autonomie/Bildung",
      "Treffpunkte TN Tage Angehörige Förderung der Autonomie/Bildung",
      "Treffpunkte TN Tage nicht Bezugsberechtigte Förderung der Autonomie/Bildung",
      "Treffpunkte TN Tage Total Förderung der Autonomie/Bildung",

      "LUFEB Stunden Angestellte: Förderung der Selbsthilfe / Unterstützung von Selbsthilfeorganisationen und -gruppen sowie Einzelpersonen",
      "LUFEB Stunden Angestellte: Allgemeine Medien- und Öffentlichkeitsarbeit",
      "LUFEB Stunden Angestellte: Themenspezifische Grundlagenarbeit / Projekte",
      "LUFEB Stunden Angestellte: Medien und Publikationen",
      "LUFEB Stunden Angestellte: Grundlagenarbeite Kurse & Treffpunkte",

      "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Förderung der Selbsthilfe / Unterstützung von Selbsthilfeorganisationen und -gruppen sowie Einzelpersonen",
      "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Allgemeine Medien- und Öffentlichkeitsarbeit",
      "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Themenspezifische Grundlagenarbeit / Projekte",
      "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Medien und Publikationen",
      "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Grundlagenarbeite Kurse & Treffpunkte",
      "LUFEB Stunden Ehrenamtliche ohne Leistungsausweis (Total)",

      "VZÄ angestellte Mitarbeiter (ganze Organisation)",
      "VZÄ angestellte Mitarbeiter (Art. 74)",
      "VZÄ ehrenamtliche Mitarbeiter (ganze Organisation)",
      "VZÄ ehrenamtliche Mitarbeiter (Art. 74)",
      "VZÄ ehrenamtliche Mitarbeiter mit Leistungsausweis (Art. 74)",

      "Geschlüsseltes Kapitalsubstrat nach Art. 74",
      "Totaler Aufwand gemäss FIBU",
      "Vollkosten nach Umlagen Betrieb Art. 74",
      "IV-Beitrag",
      "Deckungsbeitrag 4"
    ]
  end

  context 'contains correct summed values' do
    let(:data) do
      data = export(figures)
      data.each { |d| d.collect! { |i| i.is_a?(BigDecimal) ? i.to_f.round(5) : i } }
      data
    end

    it 'for insieme Schweiz' do
      expect(data.first).to match_array [
        "insieme Schweiz", nil, nil, nil,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        -200000.0, 0.0, 0.0, 0.0, 0.0
      ]
    end

    it 'for Freiburg' do
      expect(data.second).to match_array [
        "Freiburg", "Freiburg", nil, nil,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        1, 0.0, 1545.0, 0.0, 0.0, 1545.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        2, 1100.0, 8500.0, 0.0, 1664.0, 10164.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0, 12, 0, 0,
        0, 21, 0, 0, 0,
        0,
        2.0, 1.6, (21.0/1900).round(5), (21.0/1900).round(5), (21.0/1900).round(5),
        -185550.0, 0.0, 1100.0, 0.0, -1100.0
      ]
    end

    it 'for Kanton Bern' do
      expect(data.third).to match_array [
        "Kanton Bern", "Bern", nil, nil,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        4, 2100.0, 6400.0, 1111.0, 8450.0, 15961.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        1, 410.0, 1428.0, 0.0, 0.0, 1428.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        30,
        0.25, 0.25, (30.0/1900).round(5), (30.0/1900).round(5), 0.0,
        10_074_000.0, 100.0, 2050.0, 20.0, -2000.0
      ]
    end

    it 'for Biel-Seeland' do
      expect(data.fourth).to match_array [
        'Biel-Seeland', 'Bern', nil, nil,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0.0, 0.0, 0.0, 0.0, 0.0,
        -200000.0, 0.0, 0.0, 0.0, 0.0
      ]
    end
  end

  private

  def create_course(year, group_key, leistungskategorie, kategorie, attrs)
    event = Fabricate(:course,
                      leistungskategorie: leistungskategorie,
                      fachkonzept: 'sport_jugend')
    event.update(groups: [groups(group_key)])
    event.dates.create!(start_at: Time.zone.local(year, 05, 11))
    r = Event::CourseRecord.create!(attrs.merge(event_id: event.id, year: year))
    r.update_column(:zugeteilte_kategorie, kategorie)
  end


end
