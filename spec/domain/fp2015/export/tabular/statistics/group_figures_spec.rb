# frozen_string_literal: true

#  Copyright (c) 2016, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Fp2015::Export::Tabular::Statistics::GroupFigures do
  let(:year) { 2016 }

  before do
    TimeRecord::EmployeeTime.create!(group: groups(:be),
      year: year,
      interviews: 10,
      employee_pensum_attributes: {paragraph_74: 0.25})
    TimeRecord::EmployeeTime.create!(group: groups(:be), year: 2015, newsletter: 11)
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
      group: groups(:be), year: year, organization_capital: 500_000, fund_building: 25_000
    )
    CapitalSubstrate.create!(
      group: groups(:fr), year: year, organization_capital: 250_000, fund_building: 15_000
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

    # other year
    create_course(year - 1, :fr, "bk", "1", kursdauer: 17, teilnehmende_weitere: 105)
  end

  let(:figures) { fp_class("Statistics::GroupFigures").new(year) }

  def export(figures)
    exporter = described_class.new(figures)
    exporter.data_rows.to_a
  end

  it "contains correct headers" do
    labels = described_class.new(figures).labels
    expect(labels).to eq ["Vollständiger Name",
      "Kanton",
      "VID",
      "BSV Nummer",
      "Blockkurse Anzahl Kurse Kat. 1",
      "Blockkurse Total Vollkosten Kat. 1",
      "Blockkurse TN Tage Personen mit Behinderung Kat. 1",
      "Blockkurse TN Tage Angehörige Kat. 1",
      "Blockkurse TN Tage nicht Bezugsberechtigte Kat. 1",
      "Blockkurse TN Tage Total Kat. 1",

      "Blockkurse Anzahl Kurse Kat. 2",
      "Blockkurse Total Vollkosten Kat. 2",
      "Blockkurse TN Tage Personen mit Behinderung Kat. 2",
      "Blockkurse TN Tage Angehörige Kat. 2",
      "Blockkurse TN Tage nicht Bezugsberechtigte Kat. 2",
      "Blockkurse TN Tage Total Kat. 2",

      "Blockkurse Anzahl Kurse Kat. 3",
      "Blockkurse Total Vollkosten Kat. 3",
      "Blockkurse TN Tage Personen mit Behinderung Kat. 3",
      "Blockkurse TN Tage Angehörige Kat. 3",
      "Blockkurse TN Tage nicht Bezugsberechtigte Kat. 3",
      "Blockkurse TN Tage Total Kat. 3",

      "Tageskurse Anzahl Kurse Kat. 1",
      "Tageskurse Total Vollkosten Kat. 1",
      "Tageskurse TN Tage Personen mit Behinderung Kat. 1",
      "Tageskurse TN Tage Angehörige Kat. 1",
      "Tageskurse TN Tage nicht Bezugsberechtigte Kat. 1",
      "Tageskurse TN Tage Total Kat. 1",

      "Tageskurse Anzahl Kurse Kat. 2",
      "Tageskurse Total Vollkosten Kat. 2",
      "Tageskurse TN Tage Personen mit Behinderung Kat. 2",
      "Tageskurse TN Tage Angehörige Kat. 2",
      "Tageskurse TN Tage nicht Bezugsberechtigte Kat. 2",
      "Tageskurse TN Tage Total Kat. 2",

      "Tageskurse Anzahl Kurse Kat. 3",
      "Tageskurse Total Vollkosten Kat. 3",
      "Tageskurse TN Tage Personen mit Behinderung Kat. 3",
      "Tageskurse TN Tage Angehörige Kat. 3",
      "Tageskurse TN Tage nicht Bezugsberechtigte Kat. 3",
      "Tageskurse TN Tage Total Kat. 3",

      "Semester-/Jahreskurse Anzahl Kurse Kat. 1",
      "Semester-/Jahreskurse Total Vollkosten Kat. 1",
      "Semester-/Jahreskurse TN Tage Personen mit Behinderung Kat. 1",
      "Semester-/Jahreskurse TN Tage Angehörige Kat. 1",
      "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Kat. 1",
      "Semester-/Jahreskurse TN Tage Total Kat. 1",

      "Treffpunkte Anzahl Kurse Kat. 1",
      "Treffpunkte Total Vollkosten Kat. 1",
      "Treffpunkte TN Tage Personen mit Behinderung Kat. 1",
      "Treffpunkte TN Tage Angehörige Kat. 1",
      "Treffpunkte TN Tage nicht Bezugsberechtigte Kat. 1",
      "Treffpunkte TN Tage Total Kat. 1",

      "LUFEB Stunden Angestellte: Allgemeine Medien- und Öffentlichkeitsarbeit",
      "LUFEB Stunden Angestellte: Eigene öffentlich zugängliche Medien und Publikationen",
      "LUFEB Stunden Angestellte: Themenspezifische Grundlagenarbeit / Projekte",
      # rubocop:todo Layout/LineLength
      "LUFEB Stunden Angestellte: Förderung der Selbsthilfe / Unterstützung von Selbsthilfeorganisationen und -gruppen sowie Einzelpersonen",
      # rubocop:enable Layout/LineLength

      # rubocop:todo Layout/LineLength
      "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Allgemeine Medien- und Öffentlichkeitsarbeit",
      # rubocop:enable Layout/LineLength
      # rubocop:todo Layout/LineLength
      "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Eigene öffentlich zugängliche Medien und Publikationen",
      # rubocop:enable Layout/LineLength
      # rubocop:todo Layout/LineLength
      "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Themenspezifische Grundlagenarbeit / Projekte",
      # rubocop:enable Layout/LineLength
      # rubocop:todo Layout/LineLength
      "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Förderung der Selbsthilfe / Unterstützung von Selbsthilfeorganisationen und -gruppen sowie Einzelpersonen",
      # rubocop:enable Layout/LineLength

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
      "Deckungsbeitrag 4"]
  end

  it "contains correct summed values" do
    data = export(figures)
    data.each { |d| d.collect! { |i| i.is_a?(BigDecimal) ? i.to_f.round(5) : i } }

    expect(data.first).to eq [
      "insieme Schweiz", nil, nil, 2343,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0, 0, 0,
      0, 0, 0, 0,
      0,
      0.0, 0.0, 0.0, 0.0, 0.0,
      -200000.0, 0.0, 0.0, 0.0, 0.0
    ]

    expect(data.second).to eq [
      "Biel-Seeland", "Bern", nil, 3115,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0, 0, 0,
      0, 0, 0, 0,
      0,
      0.0, 0.0, 0.0, 0.0, 0.0,
      -200000.0, 0.0, 0.0, 0.0, 0.0
    ]

    expect(data.third).to eq [
      "Freiburg", "Freiburg", nil, 12607,
      1, 0.0, 1545.0, 0.0, 0.0, 1545.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      1, 500.0, 0.0, 0.0, 1664.0, 1664.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      1, 600.0, 8500.0, 0.0, 0.0, 8500.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0, 12, 0,
      21, 0, 0, 0,
      0,
      2.0, 1.6, (21.0 / 1900).round(5), (21.0 / 1900).round(5), (21.0 / 1900).round(5),
      -185550.0, 0.0, 1100.0, 0.0, -1100.0
    ]

    expect(data.fourth).to eq [
      "Kanton Bern", "Bern", nil, 2024,
      2, 1100.0, 1000.0, 1111.0, 0.0, 2111.0,
      1, 800.0, 5400.0, 0.0, 0.0, 5400.0,
      1, 200.0, 0.0, 0.0, 8450.0, 8450.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      1, 410.0, 1428.0, 0.0, 0.0, 1428.0,
      0, 0.0, 0.0, 0.0, 0.0, 0.0,
      10, 0, 0, 0,
      0, 0, 0, 20,
      30,
      0.25, 0.25, (50.0 / 1900).round(5), (50.0 / 1900).round(5), (20.0 / 1900).round(5),
      10_074_000.0, 100.0, 2050.0, 20.0, -2000.0
    ]
  end

  def create_course(year, group_key, leistungskategorie, kategorie, attrs)
    event = Fabricate(:course, groups: [groups(group_key)],
      leistungskategorie: leistungskategorie,
      fachkonzept: "sport_jugend")
    event.dates.create!(start_at: Time.zone.local(year, 0o5, 11))
    r = Event::CourseRecord.create!(attrs.merge(event_id: event.id, year: year))
    r.update_column(:zugeteilte_kategorie, kategorie)
  end
end
