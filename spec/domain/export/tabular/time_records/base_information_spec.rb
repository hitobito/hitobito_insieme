#  Copyright (c) 2016, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Export::Tabular::TimeRecords::BaseInformation do
  let(:year) { 2014 }
  let(:group) { groups(:be) }
  let(:table) { fp_class("TimeRecord::Table").new(group, year) }

  before do
    TimeRecord::EmployeeTime.create!(
      group: group, year: year, eigene_zeitschriften: 200, eigene_webseite: 330, blockkurse: 300,
      nicht_art_74_leistungen: 50,
      employee_pensum_attributes: {paragraph_74: 1.5, not_paragraph_74: 0.5}
    )
    TimeRecord::VolunteerWithVerificationTime.create!(
      group: group, year: year, kontakte_medien: 100, blockkurse: 400, verwaltung: 88,
      nicht_art_74_leistungen: 50
    )
    TimeRecord::VolunteerWithoutVerificationTime.create!(
      group: group, year: year, total_lufeb_general: 300, tageskurse: 55,
      nicht_art_74_leistungen: 50
    )
  end

  it "contains correct headers" do
    labels = described_class.new(table).labels
    expect(labels).to eq [nil, "Art. 74 betreffend", "Art. 74 nicht betreffend",
      "Ganze Organisation"]
  end

  it "contains all data" do
    data = export.each { |row| row.collect! { |v| v.is_a?(BigDecimal) ? v.to_f.round(2) : v } }
    expect(data[0]).to eq(["Angestellte MitarbeiterInnen. Gemäss Arbeitsvertrag (in 100% Stellen)",
      1.5, 0.5, 2.0])
    expect(data[1]).to eq(["Angestellte MitarbeiterInnen. Zeiterfassung (in 100% Stellen)", 0.44,
      0.03, 0.46])
    expect(data[2]).to eq(["Ehrenamtliche Arbeit ohne Leistungsnachweis (in 100% Stellen)", 0.19,
      0.03, 0.21])
    expect(data[3]).to eq(["Ehrenamtliche Arbeit mit Leistungsnachweis (in 100% Stellen)", 0.31,
      0.03, 0.34])
    expect(data[4]).to eq(["Personalaufwand inkl. Soz. Versicherung", 0.0, nil, nil])
    expect(data[5]).to eq(["Personalaufwand umgerechnet auf 100%-Stelle", 0.0, nil, nil])
    expect(data[6]).to eq(["Geschlüsseltes Kapitalsubstrat nach Art. 74 IVG", -200_000.0, nil, nil])
    expect(data[7]).to eq(["Limite Kapitalsubstrat", 0.0, nil, nil])
  end

  def export
    exporter = described_class.new(table)
    exporter.data_rows.to_a
  end
end
