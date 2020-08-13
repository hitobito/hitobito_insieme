# frozen_string_literal: true

#  Copyright (c) 2020, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Vp2020::TimeRecord::Report::CapitalSubstrateFactor do
  let(:year) { 2020 }

  let(:group) { groups(:be) }
  let(:table) { vp_class('TimeRecord::Table').new(group, year) }
  let(:report) { table.reports.fetch('capital_substrate_factor') }

  before do
    create_course_record('tk', 10)
    create_cost_accounting_report('raumaufwand', raeumlichkeiten: 100)
    create_cost_accounting_report('honorare', aufwand_ertrag_fibu: 100, verwaltung: 10,
                                              beratung: 30)
    create_report(TimeRecord::EmployeeTime, verwaltung: 50, beratung: 30, tageskurse: 20)
    CapitalSubstrate.create!(group_id: group.id, year: year, organization_capital: 300_000)
  end

  context '#paragraph_74' do
    it 'has prequisites' do
      expect(report.send(:capital_substrate)).to eq(249_850.0)
      expect(report.send(:capital_substrate_limit)).to eq(225.0)
    end

    it 'calculates the correct value' do
      expect(report.paragraph_74).to be_within(0.1).of(249_850.0 / 225.0)
      expect(report.paragraph_74).to be_within(0.1).of(1110.4)
    end

    it 'handles div/0' do
      parameter = ReportingParameter.for(year)
      parameter.update(capital_substrate_limit: 0)
      expect(parameter.capital_substrate_limit).to be_zero

      expect(report.paragraph_74).to be_zero
    end
  end

  private

  def create_cost_accounting_report(name, values)
    CostAccountingRecord.create!(values.merge(group_id: group.id,
                                              year: year,
                                              report: name))
  end

  def create_report(model_name, values)
    model_name.create!(values.merge(group_id: group.id, year: year))
  end

  def create_course_record(lk, honorare)
    Event::CourseRecord.create!(
      event: Fabricate(:aggregate_course, groups: [group], leistungskategorie: lk, fachkonzept: 'sport_jugend', year: year),
      honorare_inkl_sozialversicherung: honorare
    )
  end
end