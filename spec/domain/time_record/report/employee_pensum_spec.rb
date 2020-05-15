# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe 'TimeRecord::Report::EmployeePensum' do

  let(:year) { 2014 }
  let(:group) { groups(:be) }
  let(:table) { vp_class('TimeRecord::Table').new(group, year) }
  let(:report) { table.reports.fetch('employee_pensum') }

  before do
    create_report(TimeRecord::EmployeeTime, employee_pensum_attributes: { paragraph_74: 1,
                                                                          not_paragraph_74: 2 })
  end

  context '#paragraph_74' do
    it 'calculates the correct value' do
      expect(report.paragraph_74).to eq 1
    end
  end

  context '#not_paragraph_74' do
    it 'calculates the correct value' do
      expect(report.not_paragraph_74).to eq 2
    end
  end

  context '#total' do
    it 'calculates the correct value' do
      expect(report.total).to eq 3
    end
  end

  def create_report(model_name, values)
    model_name.create!(values.merge(group_id: group.id, year: year))
  end
end
