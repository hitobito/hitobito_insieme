# encoding: utf-8

#  Copyright (c) 2016, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe 'Export::Tabular::TimeRecords::List' do

  let(:year)  { 2014 }
  let(:group) { groups(:be) }

  context 'without records' do
    it 'contains correct headers' do
      labels = vp_class('Export::Tabular::TimeRecords::List')
                 .new(TimeRecord.where(group_id: group.id, year: year))
                 .labels
      expect(labels).to eq [nil,
                            'Zeiterfassung Angestellte',
                            'Zeiterfassung Ehrenamtliche mit Leistungsnachweis',
                            'Zeiterfassung Ehrenamtliche ohne Leistungsnachweis']
    end

    it 'contains no data' do
      export.each do |row|
        expect(row[1..-1]).to eq([nil, nil, nil])
      end
    end
  end

  context 'with records' do
    before do
      TimeRecord::EmployeeTime.create!(
        group: group, year: year, eigene_zeitschriften: 200, eigene_webseite: 330, blockkurse: 300,
        nicht_art_74_leistungen: 50,
        employee_pensum_attributes: { paragraph_74: 1.5, not_paragraph_74: 0.5 })
      TimeRecord::VolunteerWithVerificationTime.create!(
        group: group, year: year, kontakte_medien: 100, blockkurse: 400, verwaltung: 88,
        nicht_art_74_leistungen: 50)
      TimeRecord::VolunteerWithoutVerificationTime.create!(
        group: group, year: year, total_lufeb_general: 300, tageskurse: 55,
        nicht_art_74_leistungen: 50)
    end

    it 'contains all data' do
      data = [nil] + export.each { |row| row.collect! { |v| v.is_a?(BigDecimal) ? v.to_f.round(2) : v } }
      expect(data[1]).to eq(['Art. 74 betreffend in 100% Stellen', 1.5, nil, nil])
      expect(data[2]).to eq(['Art. 74 nicht betreffend in 100% Stellen', 0.5, nil, nil])
      expect(data[3]).to eq(['Total', 2.0, nil, nil])
      expect(data[4]).to eq(['Kontakte zu Medien, zu Medienschaffenden', nil, 100.0, nil])
      expect(data[5]).to eq(['Erteilen von Interviews', nil, nil, nil])

      expect(data[14]).to eq(['Allgemeine Medien- und Öffentlichkeitsarbeit', 0.0, 100.0, 300.0])
      expect(data[15]).to eq(['Eigene Zeitschriften', 200.0, nil, nil])
      expect(data[35]).to eq(['Blockkurse', 300.0, 400.0, nil])
      expect(data[36]).to eq(['Tageskurse', nil, nil, 55.0])

      expect(data[49]).to eq(['Total', 880.0, 638.0, 405.0])
      expect(data[50]).to eq(['Ausgedrückt in-100% Stellen', 0.46, 0.34, 0.21])
    end

  end

  def export
    vp_class('Export::Tabular::TimeRecords::List')
      .new(TimeRecord.where(group_id: group.id, year: year))
      .data_rows
      .to_a
  end

end
