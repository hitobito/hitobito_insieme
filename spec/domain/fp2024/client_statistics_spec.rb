# frozen_string_literal: true
require "spec_helper"

# This spec only tests the override of
#   #course_hours_including_grundlagen_hours(gcp)
# in Fp2024::Export::Tabular::CourseReporting::ClientStatistics.
# The Fp2022 base implementation adds Grundlagenstunden; the Fp2024 override
# delegates to the base *only* if the policy says to include them.
RSpec.describe Fp2024::Export::Tabular::CourseReporting::ClientStatistics do
  let(:group) { groups(:be) }

  # Minimal stub: the method under test only reads these fields.
  # See Fp2022::CourseReporting::ClientStatistics for a full description of GroupCantonParticipant.
  GcpStub = Struct.new(:group_id, :leistungskategorie, :fachkonzept, :course_hours)

  def build_gcp(fachkonzept:, hours:)
    # leistungskategorie doesn't influence grundlagen field selection except tp vs others
    lk = (fachkonzept == "treffpunkt") ? "tp" : "sk"
    GcpStub.new(group.id, lk, fachkonzept, hours)
  end

  context "policy V10 (include grundlagen hours)" do
    let(:year)  { 2024 }
    let(:stats) { instance_double("stats", year: year) }
    subject(:exporter) { described_class.new(stats) }

    before do
      # Seed employee grundlagen for 2024
      TimeRecord::EmployeeTime.create!(
        group_id: group.id, year: year, kurse_grundlagen: 20, treffpunkte_grundlagen: 30
      )
      allow(PolicyRegistry).to receive(:for).with(year: year)
        .and_return(Policies::Fsio2428::V10.new)
    end

    it "adds grundlagen for courses (non-treffpunkt)" do
      gcp = build_gcp(fachkonzept: "sport_jugend", hours: 85.0)
      result = exporter.send(:course_hours_including_grundlagen_hours, gcp)
      expect(result).to eq(85.0 + 20.0) # courses use :kurse_grundlagen
    end

    it "adds grundlagen for treffpunkt" do
      gcp = build_gcp(fachkonzept: "treffpunkt", hours: 75.0)
      result = exporter.send(:course_hours_including_grundlagen_hours, gcp)
      expect(result).to eq(75.0 + 30.0) # treffpunkt uses :treffpunkte_grundlagen
    end

    it "adds employee + volunteer grundlagen (sum of both types)" do
      # additional volunteer grundlagen for 2024
      TimeRecord::VolunteerWithVerificationTime.create!(
        group_id: group.id, year: year,
        kurse_grundlagen: 7, treffpunkte_grundlagen: 0
      )

      gcp = build_gcp(fachkonzept: "sport_jugend", hours: 5.0)
      result = exporter.send(:course_hours_including_grundlagen_hours, gcp)
      expect(result).to eq(5.0 + 20 + 7)
    end
  end

  context "policy V11 (exclude grundlagen hours)" do
    let(:year)  { 2025 }
    let(:stats) { instance_double("stats", year: year) }
    subject(:exporter) { described_class.new(stats) }

    before do
      # even if grundlagen exist, they must be ignored
      TimeRecord::EmployeeTime.create!(
        group_id: group.id, year: year, kurse_grundlagen: 999, treffpunkte_grundlagen: 888
      )
      allow(PolicyRegistry).to receive(:for).with(year: year)
        .and_return(Policies::Fsio2428::V11.new)
    end

    it "does NOT add grundlagen for courses (non-treffpunkt)" do
      gcp = build_gcp(fachkonzept: "sport_jugend", hours: 10.0)
      result = exporter.send(:course_hours_including_grundlagen_hours, gcp)
      expect(result).to eq(10.0)
    end

    it "does NOT add grundlagen for treffpunkt" do
      gcp = build_gcp(fachkonzept: "treffpunkt", hours: 7.0)
      result = exporter.send(:course_hours_including_grundlagen_hours, gcp)
      expect(result).to eq(7.0)
    end
  end
end
