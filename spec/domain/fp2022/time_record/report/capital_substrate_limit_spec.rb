# frozen_string_literal: true

#  Copyright (c) 2022, Insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later. See
#  the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Fp2022::TimeRecord::Report::CapitalSubstrateLimit do
  let(:year) { 2022 }
  let(:group) { groups(:be) }
  let(:table) { fp_class("TimeRecord::Table").new(group, year) }
  let(:report) { table.reports.fetch("capital_substrate_limit") }

  before do
    create_course_record("tk", 100) # -> 300
    create_cost_accounting_report("honorare", beratung: 300) # -> 900
  end

  context "#paragraph_74" do
    it "calculates the correct value" do
      parameter = ReportingParameter.for(year)
      expect(parameter.capital_substrate_limit).to eq(1.5)

      expect(report.paragraph_74).to eq(600)
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
      event: Fabricate(:aggregate_course, groups: [group], leistungskategorie: lk,
        fachkonzept: "sport_jugend", year: year),
      honorare_inkl_sozialversicherung: honorare
    )
  end
end
