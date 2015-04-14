# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CostAccounting::Report::UmlageRaeumlichkeiten do

  let(:year) { 2014 }
  let(:group) { groups(:be) }
  let(:table) { CostAccounting::Table.new(group, year) }
  let(:report) { table.reports.fetch('umlage_raeumlichkeiten') }
  let(:fields) { CostAccounting::Report::UmlageRaeumlichkeiten::FIELDS }


  before do
    create_report('raumaufwand', raeumlichkeiten: 100)
    create_report('honorare', verwaltung: 10, beratung: 30)
  end

  it 'defaults to nil if raumaufwand.raeumlichkeiten is nil' do
    CostAccountingRecord.find_by(report: 'raumaufwand').
      update_column(:raeumlichkeiten, nil)

    fields.each do |field|
      expect(report.send(field.to_sym)).to be_nil
    end
  end


  context 'without time record' do
    it 'allocates raeumlichkeiten proportionally' do
      expect(report.verwaltung).to eq 25
      expect(report.beratung).to eq 75
    end

    it 'total equals value of raeumlichkeiten' do
      expect(report.total).to eq 100
    end

    it 'kontrolle is 0' do
      expect(report.kontrolle).to eq 0
    end

    it 'leaves other values at 0' do
      (fields - %w(verwaltung beratung total)).each do |field|
        expect(report.send(field.to_sym)).to eq 0
      end
    end
  end

  context 'with time record' do
    it 'calculates values' do
      create_time_record(verwaltung: 50, beratung: 30, blockkurse: 20)

      expect(report.verwaltung).to eq(50)
      expect(report.beratung).to eq(30)
      expect(report.blockkurse).to eq(20)

      (fields - %w(verwaltung beratung blockkurse total)).each do |field|
        expect(report.send(field.to_sym)).to eq 0.0
      end
    end

    it 'calculates verwaltung if only verwaltung is set' do
      create_time_record(verwaltung: 50)
      expect(report.verwaltung.to_f).to eq 100.0
      expect(report.beratung.to_f).to eq 0.0
    end

    it 'total equals value of raeumlichkeiten' do
      expect(report.total).to eq 100
    end

    it 'kontrolle is 0' do
      expect(report.kontrolle).to eq 0
    end

  end

  def create_time_record(values)
    TimeRecord.create!(values.merge(group_id: group.id,
                                    year: year))
  end

  def create_report(name, values)
    CostAccountingRecord.create!(values.merge(group_id: group.id,
                                              year: year,
                                              report: name))
  end
end
