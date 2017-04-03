# encoding: utf-8

#  Copyright (c) 2016, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Export::Tabular::Events::GeneralCostAllocation do

  let(:year)  { 2014 }
  let(:group) { groups(:be) }

  context 'without entry' do
    let(:year) { 2012 }
    let(:entry) { Event::GeneralCostAllocation.new(group: group, year: year) }

    it 'contains correct headers' do
      labels = described_class.new(entry).labels
      expect(labels).to eq [nil,
                            'Total direkte Kosten',
                            'Total Gemeinkosten',
                            'Gemeinkostenzuschlag']
    end

    it 'contains blank rows' do
      data = export.each { |row| row.collect! { |v| v.is_a?(BigDecimal) ? v.to_f.round(2) : v } }
      data.each do |row|
        expect(row[1..-1]).to eq([nil, nil, nil])
      end
    end
  end

  context 'with entry' do
    let(:entry) do
      Event::GeneralCostAllocation.create!(group: group,
                                           year: 2014,
                                           general_costs_blockkurse: nil,
                                           general_costs_tageskurse: 5000,
                                           general_costs_semesterkurse: 1000)
    end

    before do
      create_course_and_course_record(group, 'bk', year: year, subventioniert: true, unterkunft: 5000)
      create_course_and_course_record(group, 'bk', year: year, subventioniert: true, unterkunft: 6000)
      create_course_and_course_record(group, 'sk', year: year, subventioniert: true, unterkunft: 3000)
    end

    it 'contains all data' do
      data = export.each { |row| row.collect! { |v| v.is_a?(BigDecimal) ? v.to_f.round(2) : v } }
      expect(data[0]).to eq(['Blockkurse', 11000.0, nil, 0.0])
      expect(data[1]).to eq(['Tageskurse', nil, 5000.0, nil])
      expect(data[2]).to eq(['Semester-/Jahreskurse', 3000.0, 1000.0, 0.33])
    end
  end

  def export
    exporter = described_class.new(entry)
    exporter.data_rows.to_a
  end

  def create_course_and_course_record(group, leistungskategorie, course_record_attrs)
    course = Event::Course.create!(name: 'dummy',
                                   groups: [ group ], leistungskategorie: leistungskategorie,
                                   dates_attributes: [{ start_at: "#{course_record_attrs.delete(:year)}-05-11" }])

    course.create_course_record!(course_record_attrs)
  end

end
