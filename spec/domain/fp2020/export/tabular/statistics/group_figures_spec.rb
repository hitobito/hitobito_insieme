# frozen_string_literal: true

#  Copyright (c) 2020-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Fp2020::Export::Tabular::Statistics::GroupFigures do
  let(:year) { 2020 }

  before do
    TimeRecord::EmployeeTime.create!(group: groups(:be),
      year: year,
      interviews: 10,
      beratung: 9,
      employee_pensum_attributes: {paragraph_74: 0.25})
    TimeRecord::EmployeeTime.create!(group: groups(:be), year: year - 1, newsletter: 11)
    TimeRecord::EmployeeTime.create!(group: groups(:fr),
      year: year,
      projekte: 12,
      employee_pensum_attributes: {
        paragraph_74: 1.6, not_paragraph_74: 0.4
      })

    TimeRecord::VolunteerWithVerificationTime.create!(
      group: groups(:be), year: year, vermittlung_kontakte: 20
    )
    TimeRecord::VolunteerWithVerificationTime.create!(
      group: groups(:fr), year: year, referate: 21
    )

    TimeRecord::VolunteerWithoutVerificationTime.create!(
      group: groups(:be), year: year, total_lufeb_promoting: 30
    )

    CostAccountingRecord.create!(group: groups(:be), year: year, report: "raumaufwand",
      raeumlichkeiten: 100)
    CostAccountingRecord.create!(group: groups(:be), year: year, report: "honorare",
      aufwand_ertrag_fibu: 100, verwaltung: 10,
      beratung: 30)
    CostAccountingRecord.create!(group: groups(:be), year: year, report: "leistungsertrag",
      aufwand_ertrag_fibu: 100, abgrenzung_fibu: 80,
      lufeb: 20)
    CostAccountingRecord.create!(group: groups(:be), year: year, report: "direkte_spenden",
      aufwand_ertrag_fibu: 10, lufeb: 2, tageskurse: 8)
    CostAccountingRecord.create!(group: groups(:be), year: year, report: "beitraege_iv",
      aufwand_ertrag_fibu: 100, abgrenzung_fibu: 80,
      lufeb: 20)

    CapitalSubstrate.create!(
      group: groups(:be), year: year, organization_capital: 500_000
    )
    CapitalSubstrate.create!(
      group: groups(:fr), year: year, organization_capital: 250_000
    )

    create_course(year, :be, "bk", "1", kursdauer: 10, unterkunft: 500,
      challenged_canton_count_attributes: {zh: 100})
    create_course(year, :be, "bk", "1", kursdauer: 11, gemeinkostenanteil: 600,
      affiliated_canton_count_attributes: {zh: 101})
    create_course(year, :be, "bk", "2", kursdauer: 12, unterkunft: 800,
      challenged_canton_count_attributes: {zh: 450})
    create_course(year, :be, "bk", "3", kursdauer: 13, teilnehmende_weitere: 650, uebriges: 200)
    create_course(year, :be, "sk", "1", kursdauer: 14, unterkunft: 400,
      honorare_inkl_sozialversicherung: 10,
      challenged_canton_count_attributes: {zh: 102})
    create_course(year, :fr, "bk", "1", kursdauer: 15, unterkunft: 0,
      challenged_canton_count_attributes: {zh: 103})
    create_course(year, :fr, "tk", "1", kursdauer: 16, teilnehmende_weitere: 104, unterkunft: 500)
    create_course(year, :fr, "tk", "3", kursdauer: 17, uebriges: 600,
      challenged_canton_count_attributes: {zh: 500})
    create_course(year, :fr, "tp", "1", kursdauer: 18, betreuerinnen: 2)

    # other year
    create_course(year - 1, :fr, "bk", "1", kursdauer: 17, teilnehmende_weitere: 105)
  end

  let(:figures) { fp_class("Statistics::GroupFigures").new(year) }

  let(:subject) { described_class.new(figures) }

  it "contains correct headers in order" do
    labels = subject.labels
    expected = [
      "Vollständiger Name",
      "Kanton",
      "VID",
      "BSV Nummer",

      "Blockkurse Anzahl Kurse Freizeit Kinder & Jugendliche",
      "Blockkurse Total Vollkosten Freizeit Kinder & Jugendliche",
      "Blockkurse TN Tage Personen mit Behinderung Freizeit Kinder & Jugendliche",
      "Blockkurse TN Tage Angehörige Freizeit Kinder & Jugendliche",
      "Blockkurse TN Tage nicht Bezugsberechtigte Freizeit Kinder & Jugendliche",
      "Blockkurse TN Tage Total Freizeit Kinder & Jugendliche",

      "Blockkurse Anzahl Kurse Freizeit Erwachsene & altersdurchmischt",
      "Blockkurse Total Vollkosten Freizeit Erwachsene & altersdurchmischt",
      "Blockkurse TN Tage Personen mit Behinderung Freizeit Erwachsene & altersdurchmischt",
      "Blockkurse TN Tage Angehörige Freizeit Erwachsene & altersdurchmischt",
      "Blockkurse TN Tage nicht Bezugsberechtigte Freizeit Erwachsene & altersdurchmischt",
      "Blockkurse TN Tage Total Freizeit Erwachsene & altersdurchmischt",

      "Blockkurse Anzahl Kurse Sport Kinder & Jugendliche",
      "Blockkurse Total Vollkosten Sport Kinder & Jugendliche",
      "Blockkurse TN Tage Personen mit Behinderung Sport Kinder & Jugendliche",
      "Blockkurse TN Tage Angehörige Sport Kinder & Jugendliche",
      "Blockkurse TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche",
      "Blockkurse TN Tage Total Sport Kinder & Jugendliche",

      "Blockkurse Anzahl Kurse Sport Erwachsene & altersdurchmischt",
      "Blockkurse Total Vollkosten Sport Erwachsene & altersdurchmischt",
      "Blockkurse TN Tage Personen mit Behinderung Sport Erwachsene & altersdurchmischt",
      "Blockkurse TN Tage Angehörige Sport Erwachsene & altersdurchmischt",
      "Blockkurse TN Tage nicht Bezugsberechtigte Sport Erwachsene & altersdurchmischt",
      "Blockkurse TN Tage Total Sport Erwachsene & altersdurchmischt",

      "Blockkurse Anzahl Kurse Förderung der Autonomie/Bildung",
      "Blockkurse Total Vollkosten Förderung der Autonomie/Bildung",
      "Blockkurse TN Tage Personen mit Behinderung Förderung der Autonomie/Bildung",
      "Blockkurse TN Tage Angehörige Förderung der Autonomie/Bildung",
      "Blockkurse TN Tage nicht Bezugsberechtigte Förderung der Autonomie/Bildung",
      "Blockkurse TN Tage Total Förderung der Autonomie/Bildung",

      "Tageskurse Anzahl Kurse Freizeit Kinder & Jugendliche",
      "Tageskurse Total Vollkosten Freizeit Kinder & Jugendliche",
      "Tageskurse TN Tage Personen mit Behinderung Freizeit Kinder & Jugendliche",
      "Tageskurse TN Tage Angehörige Freizeit Kinder & Jugendliche",
      "Tageskurse TN Tage nicht Bezugsberechtigte Freizeit Kinder & Jugendliche",
      "Tageskurse TN Tage Total Freizeit Kinder & Jugendliche",

      "Tageskurse Anzahl Kurse Freizeit Erwachsene & altersdurchmischt",
      "Tageskurse Total Vollkosten Freizeit Erwachsene & altersdurchmischt",
      "Tageskurse TN Tage Personen mit Behinderung Freizeit Erwachsene & altersdurchmischt",
      "Tageskurse TN Tage Angehörige Freizeit Erwachsene & altersdurchmischt",
      "Tageskurse TN Tage nicht Bezugsberechtigte Freizeit Erwachsene & altersdurchmischt",
      "Tageskurse TN Tage Total Freizeit Erwachsene & altersdurchmischt",

      "Tageskurse Anzahl Kurse Sport Kinder & Jugendliche",
      "Tageskurse Total Vollkosten Sport Kinder & Jugendliche",
      "Tageskurse TN Tage Personen mit Behinderung Sport Kinder & Jugendliche",
      "Tageskurse TN Tage Angehörige Sport Kinder & Jugendliche",
      "Tageskurse TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche",
      "Tageskurse TN Tage Total Sport Kinder & Jugendliche",

      "Tageskurse Anzahl Kurse Sport Erwachsene & altersdurchmischt",
      "Tageskurse Total Vollkosten Sport Erwachsene & altersdurchmischt",
      "Tageskurse TN Tage Personen mit Behinderung Sport Erwachsene & altersdurchmischt",
      "Tageskurse TN Tage Angehörige Sport Erwachsene & altersdurchmischt",
      "Tageskurse TN Tage nicht Bezugsberechtigte Sport Erwachsene & altersdurchmischt",
      "Tageskurse TN Tage Total Sport Erwachsene & altersdurchmischt",

      "Tageskurse Anzahl Kurse Förderung der Autonomie/Bildung",
      "Tageskurse Total Vollkosten Förderung der Autonomie/Bildung",
      "Tageskurse TN Tage Personen mit Behinderung Förderung der Autonomie/Bildung",
      "Tageskurse TN Tage Angehörige Förderung der Autonomie/Bildung",
      "Tageskurse TN Tage nicht Bezugsberechtigte Förderung der Autonomie/Bildung",
      "Tageskurse TN Tage Total Förderung der Autonomie/Bildung",

      "Semester-/Jahreskurse Anzahl Kurse Freizeit Kinder & Jugendliche",
      "Semester-/Jahreskurse Total Vollkosten Freizeit Kinder & Jugendliche",
      "Semester-/Jahreskurse TN Tage Personen mit Behinderung Freizeit Kinder & Jugendliche",
      "Semester-/Jahreskurse TN Tage Angehörige Freizeit Kinder & Jugendliche",
      "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Freizeit Kinder & Jugendliche",
      "Semester-/Jahreskurse TN Tage Total Freizeit Kinder & Jugendliche",

      "Semester-/Jahreskurse Anzahl Kurse Freizeit Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse Total Vollkosten Freizeit Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse TN Tage Personen mit Behinderung Freizeit Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse TN Tage Angehörige Freizeit Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Freizeit Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse TN Tage Total Freizeit Erwachsene & altersdurchmischt",

      "Semester-/Jahreskurse Anzahl Kurse Sport Kinder & Jugendliche",
      "Semester-/Jahreskurse Total Vollkosten Sport Kinder & Jugendliche",
      "Semester-/Jahreskurse TN Tage Personen mit Behinderung Sport Kinder & Jugendliche",
      "Semester-/Jahreskurse TN Tage Angehörige Sport Kinder & Jugendliche",
      "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche",
      "Semester-/Jahreskurse TN Tage Total Sport Kinder & Jugendliche",

      "Semester-/Jahreskurse Anzahl Kurse Sport Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse Total Vollkosten Sport Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse TN Tage Personen mit Behinderung Sport Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse TN Tage Angehörige Sport Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Sport Erwachsene & altersdurchmischt",
      "Semester-/Jahreskurse TN Tage Total Sport Erwachsene & altersdurchmischt",

      "Semester-/Jahreskurse Anzahl Kurse Förderung der Autonomie/Bildung",
      "Semester-/Jahreskurse Total Vollkosten Förderung der Autonomie/Bildung",
      "Semester-/Jahreskurse TN Tage Personen mit Behinderung Förderung der Autonomie/Bildung",
      "Semester-/Jahreskurse TN Tage Angehörige Förderung der Autonomie/Bildung",
      "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Förderung der Autonomie/Bildung",
      "Semester-/Jahreskurse TN Tage Total Förderung der Autonomie/Bildung",

      "Treffpunkte Anzahl Kurse Treffpunkt",
      "Treffpunkte Total Vollkosten Treffpunkt",
      "Treffpunkte TN Tage Personen mit Behinderung Treffpunkt",
      "Treffpunkte TN Tage Angehörige Treffpunkt",
      "Treffpunkte TN Tage nicht Bezugsberechtigte Treffpunkt",
      "Treffpunkte TN Tage Total Treffpunkt",
      "Treffpunkte Betreuungsstunden Total Treffpunkt",

      "Stunden Angestellte: Grundlagenarbeit Kurse & Treffpunkte",
      "LUFEB Stunden Angestellte: Grundlagenarbeit zu LUFEB",
      "LUFEB Stunden Angestellte: Förderung der Selbsthilfe",
      "LUFEB Stunden Angestellte: Allgemeine Medien & Öffentlichkeitsarbeit",
      "LUFEB Stunden Angestellte: Themenspezifische Grundlagenarbeit",
      "Stunden Angestellte: Grundlagenarbeit Medien & Publikationen",
      "Stunden Angestellte: Medien & Publikationen",
      "Stunden Angestellte: Sozialberatung",

      "Stunden Ehrenamtliche mit Leistungsausweis: Grundlagenarbeit Kurse & Treffpunkte",
      "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Grundlagenarbeit zu LUFEB",
      "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Förderung der Selbsthilfe",
      "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Allgemeine Medien & Öffentlichkeitsarbeit",
      "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Themenspezifische Grundlagenarbeit",
      "Stunden Ehrenamtliche mit Leistungsausweis: Grundlagenarbeit Medien & Publikationen",
      "Stunden Ehrenamtliche mit Leistungsausweis: Medien & Publikationen",
      "Stunden Ehrenamtliche mit Leistungsausweis: Sozialberatung",

      "LUFEB Stunden Ehrenamtliche ohne Leistungsausweis (Total)",
      "Stunden Ehrenamtliche ohne Leistungsausweis: Sozialberatung",

      "VZÄ angestellte Mitarbeiter (ganze Organisation)",
      "VZÄ angestellte Mitarbeiter (Art. 74)",
      "VZÄ ehrenamtliche Mitarbeiter (ganze Organisation)",
      "VZÄ ehrenamtliche Mitarbeiter (Art. 74)",
      "VZÄ ehrenamtliche Mitarbeiter mit Leistungsausweis (Art. 74)",

      "Geschlüsseltes Kapitalsubstrat nach Art. 74",
      "Faktor Kapitalsubstrat",
      "Totaler Aufwand gemäss FIBU",
      "Vollkosten nach Umlagen Betrieb Art. 74",
      "IV-Beitrag",
      "Deckungsbeitrag 4"
    ]
    expect(labels).to match_array expected
    expect(labels).to eq expected
  end

  context "contains correct summed values" do
    let(:data) do
      subject.data_rows.to_a
        .each { |row| row.map! { |value| value.is_a?(BigDecimal) ? value.to_f.round(5) : value } }
        .map { |row| subject.labels.zip(row).to_h }
    end

    let(:empty_row) do
      {
        "BSV Nummer" => nil,
        "Blockkurse Anzahl Kurse Freizeit Erwachsene & altersdurchmischt" => 0,
        "Blockkurse Anzahl Kurse Freizeit Kinder & Jugendliche" => 0,
        "Blockkurse Anzahl Kurse Förderung der Autonomie/Bildung" => 0,
        "Blockkurse Anzahl Kurse Sport Erwachsene & altersdurchmischt" => 0,
        "Blockkurse Anzahl Kurse Sport Kinder & Jugendliche" => 0,
        "Blockkurse TN Tage Angehörige Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Blockkurse TN Tage Angehörige Freizeit Kinder & Jugendliche" => 0.0,
        "Blockkurse TN Tage Angehörige Förderung der Autonomie/Bildung" => 0.0,
        "Blockkurse TN Tage Angehörige Sport Erwachsene & altersdurchmischt" => 0.0,
        "Blockkurse TN Tage Angehörige Sport Kinder & Jugendliche" => 0.0,
        "Blockkurse TN Tage Personen mit Behinderung Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Blockkurse TN Tage Personen mit Behinderung Freizeit Kinder & Jugendliche" => 0.0,
        "Blockkurse TN Tage Personen mit Behinderung Förderung der Autonomie/Bildung" => 0.0,
        "Blockkurse TN Tage Personen mit Behinderung Sport Erwachsene & altersdurchmischt" => 0.0,
        "Blockkurse TN Tage Personen mit Behinderung Sport Kinder & Jugendliche" => 0.0,
        "Blockkurse TN Tage Total Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Blockkurse TN Tage Total Freizeit Kinder & Jugendliche" => 0.0,
        "Blockkurse TN Tage Total Förderung der Autonomie/Bildung" => 0.0,
        "Blockkurse TN Tage Total Sport Erwachsene & altersdurchmischt" => 0.0,
        "Blockkurse TN Tage Total Sport Kinder & Jugendliche" => 0.0,
        "Blockkurse TN Tage nicht Bezugsberechtigte Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Blockkurse TN Tage nicht Bezugsberechtigte Freizeit Kinder & Jugendliche" => 0.0,
        "Blockkurse TN Tage nicht Bezugsberechtigte Förderung der Autonomie/Bildung" => 0.0,
        "Blockkurse TN Tage nicht Bezugsberechtigte Sport Erwachsene & altersdurchmischt" => 0.0,
        "Blockkurse TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche" => 0.0,
        "Blockkurse Total Vollkosten Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Blockkurse Total Vollkosten Freizeit Kinder & Jugendliche" => 0.0,
        "Blockkurse Total Vollkosten Förderung der Autonomie/Bildung" => 0.0,
        "Blockkurse Total Vollkosten Sport Erwachsene & altersdurchmischt" => 0.0,
        "Blockkurse Total Vollkosten Sport Kinder & Jugendliche" => 0.0,
        "Deckungsbeitrag 4" => 0.0,
        "Faktor Kapitalsubstrat" => 0.0,
        "Geschlüsseltes Kapitalsubstrat nach Art. 74" => 0.0,
        "IV-Beitrag" => 0.0,
        "Kanton" => nil,
        "LUFEB Stunden Angestellte: Allgemeine Medien & Öffentlichkeitsarbeit" => 0,
        "LUFEB Stunden Angestellte: Förderung der Selbsthilfe" => 0,
        "LUFEB Stunden Angestellte: Grundlagenarbeit zu LUFEB" => 0,
        "LUFEB Stunden Angestellte: Themenspezifische Grundlagenarbeit" => 0,
        "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Allgemeine Medien & Öffentlichkeitsarbeit" => 0,
        "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Förderung der Selbsthilfe" => 0,
        "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Grundlagenarbeit zu LUFEB" => 0,
        "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Themenspezifische Grundlagenarbeit" => 0,
        "LUFEB Stunden Ehrenamtliche ohne Leistungsausweis (Total)" => 0,
        "Semester-/Jahreskurse Anzahl Kurse Freizeit Erwachsene & altersdurchmischt" => 0,
        "Semester-/Jahreskurse Anzahl Kurse Freizeit Kinder & Jugendliche" => 0,
        "Semester-/Jahreskurse Anzahl Kurse Förderung der Autonomie/Bildung" => 0,
        "Semester-/Jahreskurse Anzahl Kurse Sport Erwachsene & altersdurchmischt" => 0,
        "Semester-/Jahreskurse Anzahl Kurse Sport Kinder & Jugendliche" => 0,
        "Semester-/Jahreskurse TN Tage Angehörige Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Semester-/Jahreskurse TN Tage Angehörige Freizeit Kinder & Jugendliche" => 0.0,
        "Semester-/Jahreskurse TN Tage Angehörige Förderung der Autonomie/Bildung" => 0.0,
        "Semester-/Jahreskurse TN Tage Angehörige Sport Erwachsene & altersdurchmischt" => 0.0,
        "Semester-/Jahreskurse TN Tage Angehörige Sport Kinder & Jugendliche" => 0.0,
        "Semester-/Jahreskurse TN Tage Personen mit Behinderung Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Semester-/Jahreskurse TN Tage Personen mit Behinderung Freizeit Kinder & Jugendliche" => 0.0,
        "Semester-/Jahreskurse TN Tage Personen mit Behinderung Förderung der Autonomie/Bildung" => 0.0,
        "Semester-/Jahreskurse TN Tage Personen mit Behinderung Sport Erwachsene & altersdurchmischt" => 0.0,
        "Semester-/Jahreskurse TN Tage Personen mit Behinderung Sport Kinder & Jugendliche" => 0.0,
        "Semester-/Jahreskurse TN Tage Total Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Semester-/Jahreskurse TN Tage Total Freizeit Kinder & Jugendliche" => 0.0,
        "Semester-/Jahreskurse TN Tage Total Förderung der Autonomie/Bildung" => 0.0,
        "Semester-/Jahreskurse TN Tage Total Sport Erwachsene & altersdurchmischt" => 0.0,
        "Semester-/Jahreskurse TN Tage Total Sport Kinder & Jugendliche" => 0.0,
        "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Freizeit Kinder & Jugendliche" => 0.0,
        "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Förderung der Autonomie/Bildung" => 0.0,
        "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Sport Erwachsene & altersdurchmischt" => 0.0,
        "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche" => 0.0,
        "Semester-/Jahreskurse Total Vollkosten Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Semester-/Jahreskurse Total Vollkosten Freizeit Kinder & Jugendliche" => 0.0,
        "Semester-/Jahreskurse Total Vollkosten Förderung der Autonomie/Bildung" => 0.0,
        "Semester-/Jahreskurse Total Vollkosten Sport Erwachsene & altersdurchmischt" => 0.0,
        "Semester-/Jahreskurse Total Vollkosten Sport Kinder & Jugendliche" => 0.0,
        "Stunden Angestellte: Grundlagenarbeit Kurse & Treffpunkte" => 0,
        "Stunden Angestellte: Grundlagenarbeit Medien & Publikationen" => 0,
        "Stunden Angestellte: Medien & Publikationen" => 0,
        "Stunden Angestellte: Sozialberatung" => 0,
        "Stunden Ehrenamtliche mit Leistungsausweis: Grundlagenarbeit Kurse & Treffpunkte" => 0,
        "Stunden Ehrenamtliche mit Leistungsausweis: Grundlagenarbeit Medien & Publikationen" => 0,
        "Stunden Ehrenamtliche mit Leistungsausweis: Medien & Publikationen" => 0,
        "Stunden Ehrenamtliche mit Leistungsausweis: Sozialberatung" => 0,
        "Stunden Ehrenamtliche ohne Leistungsausweis: Sozialberatung" => 0,
        "Tageskurse Anzahl Kurse Freizeit Erwachsene & altersdurchmischt" => 0,
        "Tageskurse Anzahl Kurse Freizeit Kinder & Jugendliche" => 0,
        "Tageskurse Anzahl Kurse Förderung der Autonomie/Bildung" => 0,
        "Tageskurse Anzahl Kurse Sport Erwachsene & altersdurchmischt" => 0,
        "Tageskurse Anzahl Kurse Sport Kinder & Jugendliche" => 0,
        "Tageskurse TN Tage Angehörige Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Tageskurse TN Tage Angehörige Freizeit Kinder & Jugendliche" => 0.0,
        "Tageskurse TN Tage Angehörige Förderung der Autonomie/Bildung" => 0.0,
        "Tageskurse TN Tage Angehörige Sport Erwachsene & altersdurchmischt" => 0.0,
        "Tageskurse TN Tage Angehörige Sport Kinder & Jugendliche" => 0.0,
        "Tageskurse TN Tage Personen mit Behinderung Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Tageskurse TN Tage Personen mit Behinderung Freizeit Kinder & Jugendliche" => 0.0,
        "Tageskurse TN Tage Personen mit Behinderung Förderung der Autonomie/Bildung" => 0.0,
        "Tageskurse TN Tage Personen mit Behinderung Sport Erwachsene & altersdurchmischt" => 0.0,
        "Tageskurse TN Tage Personen mit Behinderung Sport Kinder & Jugendliche" => 0.0,
        "Tageskurse TN Tage Total Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Tageskurse TN Tage Total Freizeit Kinder & Jugendliche" => 0.0,
        "Tageskurse TN Tage Total Förderung der Autonomie/Bildung" => 0.0,
        "Tageskurse TN Tage Total Sport Erwachsene & altersdurchmischt" => 0.0,
        "Tageskurse TN Tage Total Sport Kinder & Jugendliche" => 0.0,
        "Tageskurse TN Tage nicht Bezugsberechtigte Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Tageskurse TN Tage nicht Bezugsberechtigte Freizeit Kinder & Jugendliche" => 0.0,
        "Tageskurse TN Tage nicht Bezugsberechtigte Förderung der Autonomie/Bildung" => 0.0,
        "Tageskurse TN Tage nicht Bezugsberechtigte Sport Erwachsene & altersdurchmischt" => 0.0,
        "Tageskurse TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche" => 0.0,
        "Tageskurse Total Vollkosten Freizeit Erwachsene & altersdurchmischt" => 0.0,
        "Tageskurse Total Vollkosten Freizeit Kinder & Jugendliche" => 0.0,
        "Tageskurse Total Vollkosten Förderung der Autonomie/Bildung" => 0.0,
        "Tageskurse Total Vollkosten Sport Erwachsene & altersdurchmischt" => 0.0,
        "Tageskurse Total Vollkosten Sport Kinder & Jugendliche" => 0.0,
        "Totaler Aufwand gemäss FIBU" => 0.0,
        "Treffpunkte Betreuungsstunden Total Treffpunkt" => 0.0,
        "Treffpunkte Anzahl Kurse Treffpunkt" => 0,
        "Treffpunkte TN Tage Angehörige Treffpunkt" => 0.0,
        "Treffpunkte TN Tage Personen mit Behinderung Treffpunkt" => 0.0,
        "Treffpunkte TN Tage Total Treffpunkt" => 0.0,
        "Treffpunkte TN Tage nicht Bezugsberechtigte Treffpunkt" => 0.0,
        "Treffpunkte Total Vollkosten Treffpunkt" => 0.0,
        "VID" => nil,
        "VZÄ angestellte Mitarbeiter (Art. 74)" => 0.0,
        "VZÄ angestellte Mitarbeiter (ganze Organisation)" => 0.0,
        "VZÄ ehrenamtliche Mitarbeiter (Art. 74)" => 0.0,
        "VZÄ ehrenamtliche Mitarbeiter (ganze Organisation)" => 0.0,
        "VZÄ ehrenamtliche Mitarbeiter mit Leistungsausweis (Art. 74)" => 0.0,
        "Vollkosten nach Umlagen Betrieb Art. 74" => 0.0
      }
    end

    it "for insieme Schweiz" do
      expect(data.first).to include(empty_row.merge({
        "Vollständiger Name" => "insieme Schweiz",
        "Kanton" => nil,
        "VID" => nil,
        "BSV Nummer" => 2343,

        "Geschlüsseltes Kapitalsubstrat nach Art. 74" => -200_000.0,
        "Faktor Kapitalsubstrat" => 0.0,
        "Totaler Aufwand gemäss FIBU" => 0.0,
        "Vollkosten nach Umlagen Betrieb Art. 74" => 0.0,
        "IV-Beitrag" => 0.0,
        "Deckungsbeitrag 4" => 0.0
      }))
    end

    it "for Freiburg" do
      expect(data.third).to include(empty_row.merge({
        "Vollständiger Name" => "Freiburg",
        "Kanton" => "Freiburg",
        "VID" => nil,
        "BSV Nummer" => 12607,

        "Blockkurse Anzahl Kurse Sport Kinder & Jugendliche" => 1,
        "Blockkurse TN Tage Angehörige Sport Kinder & Jugendliche" => 0.0,
        "Blockkurse TN Tage Personen mit Behinderung Sport Kinder & Jugendliche" => 1545.0,
        "Blockkurse TN Tage Total Sport Kinder & Jugendliche" => 1545.0,
        "Blockkurse TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche" => 0.0,
        "Blockkurse Total Vollkosten Sport Kinder & Jugendliche" => 0.0,

        "LUFEB Stunden Angestellte: Themenspezifische Grundlagenarbeit" => 12,
        "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Allgemeine Medien & Öffentlichkeitsarbeit" => 21,
        "LUFEB Stunden Ehrenamtliche ohne Leistungsausweis (Total)" => 0,

        "Tageskurse Anzahl Kurse Sport Kinder & Jugendliche" => 2,
        "Tageskurse TN Tage Angehörige Sport Kinder & Jugendliche" => 0.0,
        "Tageskurse TN Tage Personen mit Behinderung Sport Kinder & Jugendliche" => 8500.0,
        "Tageskurse TN Tage Total Sport Kinder & Jugendliche" => 10164.0,
        "Tageskurse TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche" => 1664.0,
        "Tageskurse Total Vollkosten Sport Kinder & Jugendliche" => 1100.0,

        "Treffpunkte Anzahl Kurse Treffpunkt" => 1,
        "Treffpunkte Betreuungsstunden Total Treffpunkt" => 36.0, # 18 Stunden * 2 BetreuerInnen

        "VZÄ angestellte Mitarbeiter (Art. 74)" => 1.6,
        "VZÄ angestellte Mitarbeiter (ganze Organisation)" => 2.0,
        # 21 Stunden für LUFEB / 1900 BSV-Stunden = 0.01105
        "VZÄ ehrenamtliche Mitarbeiter (Art. 74)" => (21.0 / 1900).round(5),
        "VZÄ ehrenamtliche Mitarbeiter (ganze Organisation)" => (21.0 / 1900).round(5),
        "VZÄ ehrenamtliche Mitarbeiter mit Leistungsausweis (Art. 74)" => (21.0 / 1900).round(5),

        "Geschlüsseltes Kapitalsubstrat nach Art. 74" => -201100.0,
        "Faktor Kapitalsubstrat" => -182.81818,
        "Totaler Aufwand gemäss FIBU" => 0.0,
        "Vollkosten nach Umlagen Betrieb Art. 74" => 1100.0,
        "IV-Beitrag" => 0.0,
        "Deckungsbeitrag 4" => -1100.0
      }))
    end

    it "for Kanton Bern" do
      # 30 Stunden für LUFEB / 1900 BSV-Stunden
      expect(data.fourth).to include(empty_row.merge({
        "Vollständiger Name" => "Kanton Bern",
        "Kanton" => "Bern",
        "BSV Nummer" => 2024,
        "VID" => nil,

        "Blockkurse Anzahl Kurse Sport Kinder & Jugendliche" => 4,
        "Blockkurse TN Tage Angehörige Sport Kinder & Jugendliche" => 1111.0,
        "Blockkurse TN Tage Personen mit Behinderung Sport Kinder & Jugendliche" => 6400.0,
        "Blockkurse TN Tage Total Sport Kinder & Jugendliche" => 15961.0,
        "Blockkurse TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche" => 8450.0,
        "Blockkurse Total Vollkosten Sport Kinder & Jugendliche" => 2100.0,

        "Semester-/Jahreskurse Anzahl Kurse Sport Kinder & Jugendliche" => 1,
        "Semester-/Jahreskurse TN Tage Angehörige Sport Kinder & Jugendliche" => 0.0,
        "Semester-/Jahreskurse TN Tage Personen mit Behinderung Sport Kinder & Jugendliche" => 1428.0,
        "Semester-/Jahreskurse TN Tage Total Sport Kinder & Jugendliche" => 1428.0,
        "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche" => 0.0,
        "Semester-/Jahreskurse Total Vollkosten Sport Kinder & Jugendliche" => 410.0,

        "Tageskurse Anzahl Kurse Sport Kinder & Jugendliche" => 0,
        "Tageskurse TN Tage Angehörige Sport Kinder & Jugendliche" => 0.0,
        "Tageskurse TN Tage Personen mit Behinderung Sport Kinder & Jugendliche" => 0.0,
        "Tageskurse TN Tage Total Sport Kinder & Jugendliche" => 0.0,
        "Tageskurse TN Tage nicht Bezugsberechtigte Sport Kinder & Jugendliche" => 0.0,
        "Tageskurse Total Vollkosten Sport Kinder & Jugendliche" => 0.0,

        "LUFEB Stunden Angestellte: Allgemeine Medien & Öffentlichkeitsarbeit" => 0,
        "LUFEB Stunden Angestellte: Förderung der Selbsthilfe" => 0,
        "LUFEB Stunden Angestellte: Grundlagenarbeit zu LUFEB" => 0,
        "LUFEB Stunden Angestellte: Themenspezifische Grundlagenarbeit" => 0,

        "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Allgemeine Medien & Öffentlichkeitsarbeit" => 0,
        "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Förderung der Selbsthilfe" => 0,
        "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Grundlagenarbeit zu LUFEB" => 0,
        "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Themenspezifische Grundlagenarbeit" => 0,

        "LUFEB Stunden Ehrenamtliche ohne Leistungsausweis (Total)" => 30,
        "Stunden Ehrenamtliche ohne Leistungsausweis: Sozialberatung" => 0,

        "Stunden Angestellte: Grundlagenarbeit Kurse & Treffpunkte" => 0,
        "Stunden Angestellte: Grundlagenarbeit Medien & Publikationen" => 0,
        "Stunden Angestellte: Medien & Publikationen" => 0,
        "Stunden Angestellte: Sozialberatung" => 9,
        "Stunden Ehrenamtliche mit Leistungsausweis: Grundlagenarbeit Kurse & Treffpunkte" => 0,
        "Stunden Ehrenamtliche mit Leistungsausweis: Grundlagenarbeit Medien & Publikationen" => 0,
        "Stunden Ehrenamtliche mit Leistungsausweis: Medien & Publikationen" => 0,
        "Stunden Ehrenamtliche mit Leistungsausweis: Sozialberatung" => 0,

        "Treffpunkte Anzahl Kurse Treffpunkt" => 0,

        "VZÄ angestellte Mitarbeiter (Art. 74)" => 0.25,
        "VZÄ angestellte Mitarbeiter (ganze Organisation)" => 0.25,
        "VZÄ ehrenamtliche Mitarbeiter (Art. 74)" => 0.01579,
        "VZÄ ehrenamtliche Mitarbeiter (ganze Organisation)" => 0.01579,
        "VZÄ ehrenamtliche Mitarbeiter mit Leistungsausweis (Art. 74)" => 0.0,

        "Geschlüsseltes Kapitalsubstrat nach Art. 74" => 10048000.0,
        "Faktor Kapitalsubstrat" => 4901.46341,
        "Totaler Aufwand gemäss FIBU" => 100.0,
        "IV-Beitrag" => 20.0,
        "Vollkosten nach Umlagen Betrieb Art. 74" => 2050.0,
        "Deckungsbeitrag 4" => -2000.0
      }))
    end

    it "for Biel-Seeland" do
      expect(data.second).to include(empty_row.merge({
        "Vollständiger Name" => "Biel-Seeland",
        "Kanton" => "Bern",
        "BSV Nummer" => 3115,

        "Geschlüsseltes Kapitalsubstrat nach Art. 74" => -200_000.0,
        "Faktor Kapitalsubstrat" => 0.0,
        "Totaler Aufwand gemäss FIBU" => 0.0,
        "Vollkosten nach Umlagen Betrieb Art. 74" => 0.0,
        "IV-Beitrag" => 0.0,
        "Deckungsbeitrag 4" => 0.0
      }))
    end
  end

  private

  def create_course(year, group_key, leistungskategorie, kategorie, attrs)
    fachkonzept = (leistungskategorie == "tp") ? "treffpunkt" : "sport_jugend"

    event = Fabricate(:course, leistungskategorie: leistungskategorie, fachkonzept: fachkonzept)
    event.update(groups: [groups(group_key)])
    event.dates.create!(start_at: Time.zone.local(year, 0o5, 11))

    r = Event::CourseRecord.create!(attrs.merge(event_id: event.id, year: year))
    r.update_column(:zugeteilte_kategorie, kategorie)
  end
end
