# frozen_string_literal: true

#  Copyright (c) 2020-2022, Insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later. See
#  the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Featureperioden::Domain do
  include Featureperioden::Domain
  attr_reader :year

  def set_year(y)
    @year = y
    remove_instance_variable(:@featureperiode) if instance_variable_defined?(:@featureperiode)
  end

  before do
    # Create a class that exists only in fp2022 for forward-fill test
    stub_const("Fp2022::DummyOnlyHere", Class.new)
  end

  it "resolves to Fp2015 when year is before 2020" do
    set_year(2019)
    expect(fp_class("Statistics::GroupFigures")).to eq(Fp2015::Statistics::GroupFigures)
  end

  it "resolves to Fp2020 when year is in 2020–2021" do
    set_year(2021)
    expect(fp_class("CostAccounting::Aggregation")).to eq(Fp2020::CostAccounting::Aggregation)
  end

  it "resolves to Fp2022 when year is 2022" do
    set_year(2022)
    expect(fp_class("TimeRecord::Table")).to eq(Fp2022::TimeRecord::Table)
  end

  it "resolves to Fp2022 when year is 2023" do
    set_year(2023)
    expect(fp_class("CourseReporting::ClientStatistics")).to eq(Fp2022::CourseReporting::ClientStatistics)
  end

  it "falls back to Fp2022 when missing in Fp2024" do
    set_year(2024)
    expect(fp_class("TimeRecord::Table")).to eq(Fp2022::TimeRecord::Table)
  end

  it "raises a clear error when no FP defines the class" do
    set_year(2024)
    expect { fp_class("Completely::Missing") }
      .to raise_error(NameError, /Class Completely::Missing not found in FP chain:/)
  end

  it "does not forward-fill from newer FPs" do
    set_year(2021)
    expect { fp_class("DummyOnlyHere") }.to raise_error(NameError)
  end

  it "resolves fp2022-only class for 2022" do
    set_year(2022)
    expect(fp_class("DummyOnlyHere")).to eq(Fp2022::DummyOnlyHere)
  end

  it "falls back to Fp2022 for fp2022-only class for 2024 onwards" do
    set_year(2024)
    expect(fp_class("DummyOnlyHere")).to eq(Fp2022::DummyOnlyHere)
  end

  context "with overridden classes in newer FP" do
    before do
      # Base in Fp2022
      stub_const("Fp2022::OverrideDemo", Module.new)
      stub_const("Fp2022::OverrideDemo::Thing", Class.new)

      # Override in Fp2024
      stub_const("Fp2024::OverrideDemo", Module.new)
      stub_const("Fp2024::OverrideDemo::Thing", Class.new(Fp2022::OverrideDemo::Thing))
    end

    it "falls back to Fp2022 for 2023" do
      set_year(2023)
      expect(fp_class("OverrideDemo::Thing")).to be(Fp2022::OverrideDemo::Thing)
    end

    it "uses Fp2024 override for 2024 onwards" do
      set_year(2024)
      expect(fp_class("OverrideDemo::Thing")).to be(Fp2024::OverrideDemo::Thing)

      set_year(2025)
      expect(fp_class("OverrideDemo::Thing")).to be(Fp2024::OverrideDemo::Thing)
    end
  end
end
