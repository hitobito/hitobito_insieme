# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Export::Csv::Statistics::GroupFigures do

  before do
    TimeRecord::EmployeeTime.create!(group: groups(:be), year: 2015, interviews: 10)
    TimeRecord::EmployeeTime.create!(group: groups(:be), year: 2014, newsletter: 11)
    TimeRecord::EmployeeTime.create!(group: groups(:fr), year: 2015, projekte: 12)

    TimeRecord::VolunteerWithVerificationTime.create!(
      group: groups(:be), year: 2015, vermittlung_kontakte: 20)
    TimeRecord::VolunteerWithVerificationTime.create!(
      group: groups(:fr), year: 2015, referate: 21)

    TimeRecord::VolunteerWithoutVerificationTime.create!(
      group: groups(:be), year: 2015, total_lufeb_promoting: 30)

    CostAccountingRecord.create!(group: groups(:be), year: 2015, report: 'raumaufwand',
                                 raeumlichkeiten: 100)
    CostAccountingRecord.create!(group: groups(:be), year: 2015, report: 'honorare',
                                 aufwand_ertrag_fibu: 100, verwaltung: 10,
                                 beratung: 30, tageskurse: 10)
    CostAccountingRecord.create!(group: groups(:be), year: 2015, report: 'leistungsertrag',
                                 aufwand_ertrag_fibu: 100, abgrenzung_fibu: 80,
                                 lufeb: 20)
    CostAccountingRecord.create!(group: groups(:be), year: 2015, report: 'direkte_spenden',
                                 aufwand_ertrag_fibu: 10, lufeb: 2, tageskurse: 8)
    CostAccountingRecord.create!(group: groups(:be), year: 2015, report: 'beitraege_iv',
                                 aufwand_ertrag_fibu: 100, abgrenzung_fibu: 80,
                                 lufeb: 20)

    CapitalSubstrate.create!(
      group: groups(:be), year: 2015, organization_capital: 500_000, fund_building: 25_000)
    CapitalSubstrate.create!(
      group: groups(:fr), year: 2015, organization_capital: 250_000, fund_building: 15_000)

    create_course(2015, :be, 'bk', '1', kursdauer: 10, challenged_canton_count_attributes: { zh: 100 }, unterkunft: 500)
    create_course(2015, :be, 'bk', '1', kursdauer: 11, affiliated_canton_count_attributes: { zh: 101 }, gemeinkostenanteil: 600)
    create_course(2015, :be, 'bk', '2', kursdauer: 12, challenged_canton_count_attributes: { zh: 450 }, unterkunft: 800)
    create_course(2015, :be, 'bk', '3', kursdauer: 13, teilnehmende_weitere: 650, uebriges: 200)
    create_course(2015, :be, 'sk', '1', kursdauer: 14, challenged_canton_count_attributes: { zh: 102 }, unterkunft: 400)
    create_course(2015, :fr, 'bk', '1', kursdauer: 15, challenged_canton_count_attributes: { zh: 103 }, unterkunft: 0)
    create_course(2015, :fr, 'tk', '1', kursdauer: 16, teilnehmende_weitere: 104, unterkunft: 500)
    create_course(2015, :fr, 'tk', '3', kursdauer: 17, challenged_canton_count_attributes: { zh: 500 }, uebriges: 600)

    # other year
    create_course(2014, :fr, 'bk', '1', kursdauer: 17, teilnehmende_weitere: 105)
  end

  let(:figures) { Statistics::GroupFigures.new(2015) }

  def export(figures)
    exporter = described_class.new(figures)
    [].tap { |csv| exporter.to_csv(csv) }
  end

  it 'contains correct headers' do
    labels = export(figures)[0]
    expect(labels).to eq ["Vollständiger Name",
                          "Kanton",
                          "VID",
                          "BSV Nummer",
                          "Blockkurse Anzahl Kurse Kat. 1",
                          "Blockkurse Total Vollkosten Kat. 1",
                          "Blockkurse TN Tage Behinderte Kat. 1",
                          "Blockkurse TN Tage Angehörige Kat. 1",
                          "Blockkurse TN Tage nicht Bezugsberechtigte Kat. 1",
                          "Blockkurse TN Tage Total Kat. 1",

                          "Blockkurse Anzahl Kurse Kat. 2",
                          "Blockkurse Total Vollkosten Kat. 2",
                          "Blockkurse TN Tage Behinderte Kat. 2",
                          "Blockkurse TN Tage Angehörige Kat. 2",
                          "Blockkurse TN Tage nicht Bezugsberechtigte Kat. 2",
                          "Blockkurse TN Tage Total Kat. 2",

                          "Blockkurse Anzahl Kurse Kat. 3",
                          "Blockkurse Total Vollkosten Kat. 3",
                          "Blockkurse TN Tage Behinderte Kat. 3",
                          "Blockkurse TN Tage Angehörige Kat. 3",
                          "Blockkurse TN Tage nicht Bezugsberechtigte Kat. 3",
                          "Blockkurse TN Tage Total Kat. 3",

                          "Tageskurse Anzahl Kurse Kat. 1",
                          "Tageskurse Total Vollkosten Kat. 1",
                          "Tageskurse TN Tage Behinderte Kat. 1",
                          "Tageskurse TN Tage Angehörige Kat. 1",
                          "Tageskurse TN Tage nicht Bezugsberechtigte Kat. 1",
                          "Tageskurse TN Tage Total Kat. 1",

                          "Tageskurse Anzahl Kurse Kat. 2",
                          "Tageskurse Total Vollkosten Kat. 2",
                          "Tageskurse TN Tage Behinderte Kat. 2",
                          "Tageskurse TN Tage Angehörige Kat. 2",
                          "Tageskurse TN Tage nicht Bezugsberechtigte Kat. 2",
                          "Tageskurse TN Tage Total Kat. 2",

                          "Tageskurse Anzahl Kurse Kat. 3",
                          "Tageskurse Total Vollkosten Kat. 3",
                          "Tageskurse TN Tage Behinderte Kat. 3",
                          "Tageskurse TN Tage Angehörige Kat. 3",
                          "Tageskurse TN Tage nicht Bezugsberechtigte Kat. 3",
                          "Tageskurse TN Tage Total Kat. 3",

                          "Semester-/Jahreskurse Anzahl Kurse Kat. 1",
                          "Semester-/Jahreskurse Total Vollkosten Kat. 1",
                          "Semester-/Jahreskurse TN Tage Behinderte Kat. 1",
                          "Semester-/Jahreskurse TN Tage Angehörige Kat. 1",
                          "Semester-/Jahreskurse TN Tage nicht Bezugsberechtigte Kat. 1",
                          "Semester-/Jahreskurse TN Tage Total Kat. 1",

                          "LUFEB Stunden Angestellte: Allgemeine Medien- und Öffentlichkeitsarbeit",
                          "LUFEB Stunden Angestellte: Eigene öffentlich zugängliche Medien und Publikationen",
                          "LUFEB Stunden Angestellte: Themenspezifische Grundlagenarbeit / Projekte",
                          "LUFEB Stunden Angestellte: Förderung der Selbsthilfe / Unterstützung von Selbsthilfeorganisationen und -gruppen sowie Einzelpersonen",

                          "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Allgemeine Medien- und Öffentlichkeitsarbeit",
                          "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Eigene öffentlich zugängliche Medien und Publikationen",
                          "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Themenspezifische Grundlagenarbeit / Projekte",
                          "LUFEB Stunden Ehrenamtliche mit Leistungsausweis: Förderung der Selbsthilfe / Unterstützung von Selbsthilfeorganisationen und -gruppen sowie Einzelpersonen",

                          "LUFEB Stunden Ehrenamtliche ohne Leistungsausweis (Total)",

                          "VZÄ angestellte Mitarbeiter (ganze Organisation)",
                          "VZÄ angestellte Mitarbeiter (Art. 74)",
                          "VZÄ ehrenamtliche Mitarbeiter (ganze Organisation)",
                          "VZÄ ehrenamtliche Mitarbeiter (Art. 74)",

                          "Geschlüsseltes Kapitalsubstrat nach Art. 74",
                          "Totaler Aufwand gemäss FIBU",
                          "Vollkosten nach Umlagen Betrieb Art. 74",
                          "IV-Beitrag",
                          "Deckungsbeitrag 4"]
  end

  it 'contains correct summed values' do
    data = export(figures)[1..-1]
    data.each { |d| d.collect! { |i| i.is_a?(BigDecimal) ? i.to_f.round(5) : i } }
    expect(data).to eq [
      ["insieme Schweiz", nil, nil, nil,
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
       0.0, 0.0, 0.0, 0.0,
       -200000.0, 0.0, 0.0, 0.0, 0.0], #.collect(&:to_s),
      ["Freiburg", 'Freiburg', nil, nil,
       1, 0.0, 1545.0, 0.0, 0.0, 1545.0,
       0, 0.0, 0.0, 0.0, 0.0, 0.0,
       0, 0.0, 0.0, 0.0, 0.0, 0.0,
       1, 500.0, 0.0, 0.0, 1664.0, 1664.0,
       0, 0.0, 0.0, 0.0, 0.0, 0.0,
       1, 600.0, 8500.0, 0.0, 0.0, 8500.0,
       0, 0.0, 0.0, 0.0, 0.0, 0.0,
       0, 0, 12, 0,
       21, 0, 0, 0,
       0,
       (12.0/1900).round(5), (12.0/1900).round(5), (21.0/1900).round(5), (21.0/1900).round(5),
       -185000.0, 0.0, 0.0, 0.0, 0.0], #.collect(&:to_s),
      ["Kanton Bern", 'Bern', nil, nil,
       2, 1100.0, 1000.0, 1111.0, 0.0, 2111.0,
       1, 800.0, 5400.0, 0.0, 0.0, 5400.0,
       1, 200.0, 0.0, 0.0, 8450.0, 8450.0,
       0, 0.0, 0.0, 0.0, 0.0, 0.0,
       0, 0.0, 0.0, 0.0, 0.0, 0.0,
       0, 0.0, 0.0, 0.0, 0.0, 0.0,
       1, 400.0, 1428.0, 0.0, 0.0, 1428.0,
       10, 0, 0, 0,
       0, 0, 0, 20,
       30,
       (10.0/1900).round(5), (10.0/1900).round(5), (50.0/1900).round(5), (50.0/1900).round(5),
       574950.0, 100.0, 150.0, 20.0, -100.0], #.collect(&:to_s),
      ["Biel-Seeland", 'Bern', nil, nil,
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
       0.0, 0.0, 0.0, 0.0,
       -200000.0, 0.0, 0.0, 0.0, 0.0] #.collect(&:to_s)
    ]
  end

  def create_course(year, group_key, leistungskategorie, kategorie, attrs)
    event = Fabricate(:course, groups: [groups(group_key)],
                      leistungskategorie: leistungskategorie)
    event.dates.create!(start_at: Time.zone.local(year, 05, 11))
    r = Event::CourseRecord.create!(attrs.merge(event_id: event.id, year: year))
    r.update_column(:zugeteilte_kategorie, kategorie)
  end


end
