#  Copyright (c) 2012-2016, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe "CostAccounting::Report::CourseRelated" do
  let(:group) { groups(:be) }
  let(:table) { fp_class("CostAccounting::Table").new(group, year) }
  let(:report) { table.reports.fetch("raumaufwand") }

  context "based on courses" do
    let(:year) { 2016 }

    context "with cost accounting record" do
      before do
        CostAccountingRecord.create!(group_id: group.id,
          year: year,
          report: "raumaufwand",
          aufwand_ertrag_fibu: 1050,
          abgrenzung_fibu: 50)
      end

      context "with courses" do
        before { create_course_records }

        context "fields" do
          it "works if present" do
            expect(report.blockkurse).to eq 49000
          end

          it "works if nil" do
            expect(report.jahreskurse).to be_nil
          end
        end

        context "#total" do
          it "is calculated correctly" do
            expect(report.total).to eq(49050.0)
          end
        end
      end

      context "without courses" do
        context "time fields" do
          it "works if nil" do
            expect(report.blockkurse).to be_nil
          end
        end

        context "#total" do
          it "is calculated correctly" do
            expect(report.total).to eq(0.0)
          end
        end
      end
    end

    context "without cost accounting record" do
      before { create_course_records }

      context "fields" do
        it "work the same way" do
          expect(report.blockkurse).to eq(49000)
        end
        it "work the same way if nil" do
          expect(report.jahreskurse).to be_nil
        end
      end

      context "#total" do
        it "is calculated correctly" do
          expect(report.total).to eq(49050.0)
        end
      end
    end
  end

  context "based on manual values" do
    let(:year) { 2015 }

    before do
      CostAccountingRecord.create!(group_id: group.id,
        year: year,
        report: "raumaufwand",
        aufwand_ertrag_fibu: 1050,
        abgrenzung_fibu: 50,
        jahreskurse: 45_000,
        tageskurse: 30)
    end

    before { create_course_records }

    context "fields" do
      it "works if present" do
        expect(report.jahreskurse).to eq 45_000
      end

      it "works if nil" do
        expect(report.blockkurse).to be_nil
      end
    end

    context "#total" do
      it "is calculated correctly" do
        expect(report.total).to eq(45_030.0)
      end
    end
  end

  def create_course_records # rubocop:todo Metrics/MethodLength
    Event::CourseRecord.create!(
      event: Fabricate(:course,
        groups: [group],
        leistungskategorie: "bk", fachkonzept: "sport_jugend",
        dates_attributes: [{start_at: Date.new(year, 10, 1)}]),
      year: year,
      unterkunft: 5000,
      uebriges: 600
    )
    Event::CourseRecord.create!(
      event: Fabricate(:aggregate_course, groups: [group], leistungskategorie: "bk",
        fachkonzept: "sport_jugend", year: year),
      unterkunft: 44000,
      uebriges: 700
    )
    Event::CourseRecord.create!(
      event: Fabricate(:aggregate_course, groups: [group], leistungskategorie: "tk",
        fachkonzept: "sport_jugend", year: year),
      unterkunft: 50,
      uebriges: 8000
    )
    # not subventioniert are ignored
    Event::CourseRecord.create!(
      event: Fabricate(:aggregate_course, groups: [group], leistungskategorie: "bk",
        fachkonzept: "sport_jugend", year: year),
      unterkunft: 500,
      uebriges: 8000,
      subventioniert: false
    )
  end
end
