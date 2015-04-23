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

    create_course(2015, :be, 'bk', '1', 10, 100)
    create_course(2015, :be, 'bk', '1', 11, 101)
    create_course(2015, :be, 'bk', '2', 12, 450)
    create_course(2015, :be, 'bk', '3', 13, 650)
    create_course(2015, :be, 'sk', '1', 14, 102)
    create_course(2015, :fr, 'bk', '1', 15, 103)
    create_course(2015, :fr, 'tk', '1', 16, 104)
    create_course(2015, :fr, 'tk', '3', 17, 500)

    # other year
    create_course(2014, :fr, 'bk', '1', 17, 105)
  end

  let(:figures) { Statistics::GroupFigures.new(2015) }

  def export(figures)
    exporter = described_class.new(figures)
    [].tap { |csv| exporter.to_csv(csv) }
  end

  it 'contains correct headers' do
    labels = export(figures)[0]
    expect(labels).to eq ["Vollständiger Name",
                          "VID",
                          "BSV Nummer",
                          "Blockkurse TN Tage Kat. 1",
                          "Blockkurse TN Tage Kat. 2",
                          "Blockkurse TN Tage Kat. 3",
                          "Tageskurse TN Tage Kat. 1",
                          "Tageskurse TN Tage Kat. 2",
                          "Tageskurse TN Tage Kat. 3",
                          "Semester-/Jahreskurse TN Stunden Kat. 1",
                          "LUFEB Stunden Angestellte",
                          "LUFEB Stunden Ehrenamtliche mit Leistungsausweis"]
  end

  it 'contains correct summed values' do
    data = export(figures)[1..-1]
    expect(data).to eq [
      ["insieme Schweiz", nil, nil, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0],
      ["Freiburg", nil, nil, 1545.0, 0.0, 0.0, 1664.0, 0.0, 8500.0, 0.0, 12, 21],
      ["Kanton Bern", nil, nil, 2111.0, 5400.0, 8450.0, 0.0, 0.0, 0.0, 1428.0, 10, 20],
      ["Biel-Seeland", nil, nil, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0]
    ]
  end


  def create_course(year, group_key, leistungskategorie, kategorie, kursdauer, teilnehmende)
    event = Fabricate(:course, groups: [groups(group_key)],
                               leistungskategorie: leistungskategorie)
    event.dates.create!(start_at: Time.zone.local(year, 05, 11))
    r = Event::CourseRecord.create!(event_id: event.id,
                                    year: year,
                                    kursdauer: kursdauer,
                                    teilnehmende_weitere: teilnehmende)
    r.update_column(:zugeteilte_kategorie, kategorie)
  end


end
