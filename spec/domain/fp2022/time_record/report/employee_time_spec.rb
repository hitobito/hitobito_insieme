# frozen_string_literal: true

#  Copyright (c) 2022-2023, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Fp2022::TimeRecord::Report::EmployeeTime do
  let(:year) { 2022 }
  let(:group) { groups(:be) }
  let(:table) { fp_class("TimeRecord::Table").new(group, year) }
  let(:report) { table.reports.fetch("employee_time") }

  subject { report }

  before do
    create_report(TimeRecord::EmployeeTime, blockkurse: (3 * 1900), nicht_art_74_leistungen: (5 * 1900))

    # honorar_costs for 1 fte
    create_report(CostAccountingRecord, report: "honorare", aufwand_ertrag_fibu: (130 * 1900), beratung: (2 * 130 * 1900))
  end

  context "#paragraph_74" do
    it "calculates the correct value" do
      expect(report.paragraph_74).to eq BigDecimal("3")
    end
  end

  context "#not_paragraph_74" do
    it "calculates the correct value" do
      expect(report.not_paragraph_74).to eq BigDecimal("5")
    end
  end

  context "#total" do
    it "calculates the correct value" do
      expect(report.total).to eq(BigDecimal("3") + BigDecimal("5")) # 8
    end
  end

  def create_report(model_name, values)
    model_name.create!(values.merge(group_id: group.id, year: year))
  end
end
