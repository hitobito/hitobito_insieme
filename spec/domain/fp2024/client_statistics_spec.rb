# frozen_string_literal: true
require "spec_helper"

RSpec.describe Fp2024::Export::Tabular::CourseReporting::ClientStatistics do
  let(:year) { 2024 }
  let(:stats) { instance_double("stats", year: year) } # adapt if your constructor differs
  subject(:exporter) { described_class.new(stats) }

  it "calls super when policy includes grundlagen hours" do
    allow(PolicyRegistry).to receive(:for).with(year: year)
      .and_return(Policies::Fsio2428::V10.new)
    # spy on the super implementation
    expect_any_instance_of(Fp2022::Export::Tabular::CourseReporting::ClientStatistics)
      .to receive(:course_hours_including_grundlagen_hours)
    exporter.send(:course_hours_including_grundlagen_hours, double)
  end
end
