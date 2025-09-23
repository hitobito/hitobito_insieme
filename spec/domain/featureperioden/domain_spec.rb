# frozen_string_literal: true

#  Copyright (c) 2020-2022, Insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later. See
#  the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Featureperioden::Domain do
  include Featureperioden::Domain
  def year; @year; end

  before do
    # Create a class that exists only in fp2022 for this test
    stub_const('Fp2022::DummyOnlyHere', Class.new)
  end

  it "resolves to correct FP when class exists within FP" do
    @year = 2019
    expect(fp_class("Statistics::GroupFigures")).to eq Fp2015::Statistics::GroupFigures
  end

  it "resolves to correct FP when class exists within FP" do
    @year = 2021
    expect(fp_class("CostAccounting::Aggregation")).to eq Fp2020::CostAccounting::Aggregation
  end

  it "resolves to correct FP when class exists within FP" do
    @year = 2022
    expect(fp_class("TimeRecord::Table")).to eq Fp2022::TimeRecord::Table
  end

  it "resolves to correct FP when class exists within FP" do
    @year = 2023
    expect(fp_class("CourseReporting::ClientStatistics")).to eq Fp2022::CourseReporting::ClientStatistics
  end

  it "falls back to older FP when missing in newer one" do
    @year = 2024
    # Assuming TimeRecord::Table not yet overridden in Fp2024
    expect(fp_class("TimeRecord::Table")).to eq Fp2022::TimeRecord::Table
  end

  it "raises a clear error when no FP defines the class" do
    @year = 2024
    expect {
        fp_class("Completely::Missing")
    }.to raise_error(NameError, /Class Completely::Missing not found in FP chain:/)
  end

    it "does not forward-fill from newer FPs" do
    @year = 2021
    expect { fp_class('DummyOnlyHere') }.to raise_error(NameError)
  end

  it "resolves it in 2022+" do
    @year = 2022
    expect(fp_class('DummyOnlyHere')).to eq(Fp2022::DummyOnlyHere)
  end
end
