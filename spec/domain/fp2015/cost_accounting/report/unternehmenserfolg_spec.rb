#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe "CostAccounting::Report::Unternehmenserfolg" do
  let(:year) { 2016 }
  let(:group) { groups(:be) }
  let(:table) { fp_class("CostAccounting::Table").new(group, year) }
  let(:report) { table.reports.fetch("unternehmenserfolg") }

  it "sets unused fields to nil" do
    expect(report.aufwand_ertrag_ko_re).to be_nil
    expect(report.kontrolle).to be_nil
  end

  it "calculates the profit" do
    create_report("leistungsertrag", aufwand_ertrag_fibu: 100)
    create_report("raumaufwand", aufwand_ertrag_fibu: 20)
    expect(report.total).to eq(80)
  end

  it "calculates the loss" do
    create_report("leistungsertrag", aufwand_ertrag_fibu: 100)
    create_report("raumaufwand", aufwand_ertrag_fibu: 120)
    expect(report.total).to eq(-20)
  end

  def create_report(name, values)
    CostAccountingRecord.create!(values.merge(group_id: group.id,
      year: year,
      report: name))
  end
end
