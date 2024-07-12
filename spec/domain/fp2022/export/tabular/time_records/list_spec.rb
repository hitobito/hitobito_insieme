#  Copyright (c) 2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe "Export::Tabular::TimeRecords::List" do
  let(:year) { 2022 }
  let(:group) { groups(:be) }

  context "without records" do
    it "contains correct headers" do
      labels = fp_class("Export::Tabular::TimeRecords::List")
        .new(TimeRecord.where(group_id: group.id, year: year))
        .labels
      expect(labels).to eq [nil,
        "Zeiterfassung Angestellte",
        "Zeiterfassung Ehrenamtliche mit Leistungsnachweis",
        "Zeiterfassung Ehrenamtliche ohne Leistungsnachweis"]
    end

    it "contains no data" do
      export.each do |row|
        expect(row[1..]).to eq([nil, nil, nil])
      end
    end
  end

  context "with records" do
    before do
      TimeRecord::EmployeeTime.create!(
        group: group, year: year, apps: 200, website: 330, blockkurse: 300, kurse_grundlagen: 42,
        nicht_art_74_leistungen: 50,
        employee_pensum_attributes: {paragraph_74: 1.5, not_paragraph_74: 0.5}
      )
      TimeRecord::VolunteerWithVerificationTime.create!(
        group: group, year: year, lufeb_grundlagen: 100, blockkurse: 400, verwaltung: 88, treffpunkte_grundlagen: 43,
        nicht_art_74_leistungen: 50
      )
      TimeRecord::VolunteerWithoutVerificationTime.create!(
        group: group, year: year, total_lufeb_general: 300, tageskurse: 55, treffpunkte: 37,
        nicht_art_74_leistungen: 50
      )
    end

    it "contains all data" do
      data = [nil] + export.each { |row| row.collect! { |v| v.is_a?(BigDecimal) ? v.to_f.round(2) : v } }
      expect(data[1]).to eq(["Art. 74 betreffend in 100% Stellen", 1.5, nil, nil])
      expect(data[2]).to eq(["Art. 74 nicht betreffend in 100% Stellen", 0.5, nil, nil])
      expect(data[3]).to eq(["Total", 2.0, nil, nil])
      expect(data[4]).to eq(["Grundlagenarbeit zu LUFEB", nil, 100.0, nil])
      expect(data[5]).to eq(["Information / Beratung von Organisationen und Einzelpersonen", nil, nil, nil])

      expect(data[13]).to eq(["Allgemeine Medien- und Öffentlichkeitsarbeit", 0, 0, 300])

      expect(data[20]).to eq(["Grundlagenarbeit zu Medien & Publikationen", nil, nil, nil])
      expect(data[21]).to eq(["Website", 330.0, nil, nil])
      expect(data[26]).to eq(["Applikationen", 200.0, nil, nil])
      expect(data[27]).to eq(["Medien & Publikationen", 530.0, 0.0, nil])

      expect(data[28]).to eq(["Grundlagenarbeit zu Kursen", 42, nil, nil])
      expect(data[29]).to eq(["Blockkurse", 300.0, 400.0, nil])
      expect(data[30]).to eq(["Tageskurse", nil, nil, 55.0])
      expect(data[32]).to eq(["Grundlagenarbeit zu Treffpunkten", nil, 43, nil])
      expect(data[33]).to eq(["Treffpunkte", nil, nil, 37.0])

      expect(data[44]).to eq(["Total", 922.0, 681.0, 442.0])
      expect(data[45]).to eq(["Ausgedrückt in-100% Stellen", 0.49, 0.36, 0.23])
    end
  end

  def export
    fp_class("Export::Tabular::TimeRecords::List")
      .new(TimeRecord.where(group_id: group.id, year: year))
      .data_rows
      .to_a
  end
end
