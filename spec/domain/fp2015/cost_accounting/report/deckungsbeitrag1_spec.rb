#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe "CostAccounting::Report::Deckungsbeitrag1" do
  let(:year) { 2016 }
  let(:group) { groups(:be) }
  let(:table) { fp_class("CostAccounting::Table").new(group, year) }
  let(:report) { table.reports.fetch("deckungsbeitrag1") }

  before do
    create_course_record("bk", 5)
    create_course_record("tk", 4)
    create_course_record("sk", 3)
    create_report("leistungsertrag", beratung: 10, treffpunkte: 11, blockkurse: 12,
      tageskurse: 13, jahreskurse: 14, lufeb: 15, mittelbeschaffung: 16)
    create_report("raumaufwand", beratung: 7, treffpunkte: 6, lufeb: 2, mittelbeschaffung: 1)
  end

  it "sets unused fields to nil" do
    expect(report.aufteilung_kontengruppen).to be_nil
    expect(report.aufwand_ertrag_fibu).to be_nil
    expect(report.abgrenzung_fibu).to be_nil
    expect(report.abgrenzung_dachorganisation).to be_nil
    expect(report.aufwand_ertrag_ko_re).to be_nil
    expect(report.personal).to be_nil
    expect(report.raeumlichkeiten).to be_nil
    expect(report.verwaltung).to be_nil
    expect(report.kontrolle).to be_nil
  end

  it "calculates leistungsertrag - total_aufwand" do
    expect(report.beratung).to eq(10 - 7)
    expect(report.treffpunkte).to eq(11 - 6)
    expect(report.blockkurse).to eq(12 - 5)
    expect(report.tageskurse).to eq(13 - 4)
    expect(report.jahreskurse).to eq(14 - 3)
    expect(report.lufeb).to eq(15 - 2)
    expect(report.mittelbeschaffung).to eq(16 - 1)
  end

  it "calculates the correct total" do
    expect(report.total).to eq(63)
  end

  def create_report(name, values)
    CostAccountingRecord.create!(values.merge(group_id: group.id,
      year: year,
      report: name))
  end

  def create_course_record(lk, unterkunft)
    Event::CourseRecord.create!(
      event: Fabricate(:aggregate_course, groups: [group], leistungskategorie: lk, fachkonzept: "sport_jugend", year: year),
      unterkunft: unterkunft
    )
  end
end
