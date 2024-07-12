#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe "TimeRecord::Report::EmployeeEffortsPensum" do
  let(:year) { 2014 }
  let(:group) { groups(:be) }
  let(:table) { fp_class("TimeRecord::Table").new(group, year) }
  let(:report) { table.reports.fetch("employee_efforts_pensum") }

  before do
    create_cost_accounting_report("lohnaufwand", aufwand_ertrag_fibu: 5)
    create_cost_accounting_report("honorare", aufwand_ertrag_fibu: 3)
    create_report(TimeRecord::EmployeeTime, blockkurse: 2 * 1900, nicht_art_74_leistungen: 4 * 1900)
  end

  context "#paragraph_74" do
    it "calculates the correct value" do
      expect(report.paragraph_74).to eq 2.5
    end
  end

  context "#not_paragraph_74" do
    it "is nil" do
      nil
    end
  end

  context "#total" do
    it "is nil" do
      nil
    end
  end

  def create_cost_accounting_report(name, values)
    CostAccountingRecord.create!(values.merge(group_id: group.id,
      year: year,
      report: name))
  end

  def create_report(model_name, values)
    model_name.create!(values.merge(group_id: group.id, year: year))
  end
end
