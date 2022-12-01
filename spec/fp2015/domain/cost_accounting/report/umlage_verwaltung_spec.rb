# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe 'CostAccounting::Report::UmlageVerwaltung' do

  let(:year) { 2016 }
  let(:group) { groups(:be) }
  let(:table) { fp_class('CostAccounting::Table').new(group, year) }
  let(:report) { table.reports.fetch('umlage_verwaltung') }
  let(:fields) { fp_class('CostAccounting::Report::UmlageVerwaltung')::FIELDS }

  context 'verwaltung is zero' do

    before do
      create_report('raumaufwand', raeumlichkeiten: 100)
      create_report('honorare', verwaltung: 0, beratung: 30, tageskurse: 10)
    end

    it 'defaults to nil' do
      CostAccountingRecord.find_by(report: 'raumaufwand').
        update_column(:raeumlichkeiten, nil)

      fields.each do |field|
        expect(report.send(field.to_sym)).to be_nil
      end
    end

    it 'total equals value of verwaltung' do
      expect(report.total).to eq 0
    end

    it 'kontrolle is zero' do
      expect(report.kontrolle).to eq 0
    end

  end

  context 'verwaltung is given' do

    before do
      create_course_record('tk', 10)
      create_report('raumaufwand', raeumlichkeiten: 100)
      create_report('honorare', verwaltung: 10, beratung: 30)
    end

    it 'verwaltung is correct' do
      expect(report.verwaltung).to eq(30)
    end

    context 'without time record' do
      it 'allocates verwaltung proportionally' do
        expect(report.beratung).to eq 22.5
        expect(report.tageskurse).to eq 7.5
      end

      it 'total equals value of verwaltung' do
        expect(report.total).to eq 30
      end

      it 'kontrolle is zero' do
        expect(report.kontrolle).to eq 0
      end

      it 'leaves other values at 0' do
        (fields - %w(beratung tageskurse)).each do |field|
          expect(report.send(field.to_sym)).to eq 0
        end
      end
    end

    context 'with time record' do

      it 'calculates values' do
        create_time_record(verwaltung: 50, beratung: 30, tageskurse: 20)

        expect(report.verwaltung).to eq(60)
        expect(report.beratung).to eq(36)
        expect(report.tageskurse).to eq(24)
        expect(report.total).to eq(60)
        expect(report.kontrolle).to eq(0)

        (fields - %w(verwaltung beratung tageskurse)).each do |field|
          expect(report.send(field.to_sym)).to eq 0.0
        end
      end

      it 'calculates nil value for empty field of time_record' do
        create_time_record(verwaltung: 50)
        expect(report.verwaltung).to eq 110
        expect(report.beratung).to be_nil
      end
    end
  end

  def create_time_record(values)
    TimeRecord::EmployeeTime.create!(values.merge(group_id: group.id,
                                                  year: year))
  end

  def create_report(name, values)
    CostAccountingRecord.create!(values.merge(group_id: group.id,
                                              year: year,
                                              report: name))
  end

  def create_course_record(lk, honorare)
    Event::CourseRecord.create!(
      event: Fabricate(:aggregate_course, groups: [group], leistungskategorie: lk, fachkonzept: 'sport_jugend', year: year),
      honorare_inkl_sozialversicherung: honorare
    )
  end

end
