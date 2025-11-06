# frozen_string_literal: true

#  Copyright (c) 2020-2022, Insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later. See
#  the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Featureperioden::Dispatcher do
  subject { described_class.new(year) }

  let(:year) { 2020 }

  it "knows a views-path that can be prepended" do
    expect(subject.view_path.to_s).to match(%r{hitobito_insieme}) # in the wagon
    expect(subject.view_path.to_s).to match(%r{app/views/fp2020}) # a certain directory
  end

  it "can load modules from namespace" do
    expect(subject.domain_class("TimeRecord::Table")).to be Fp2020::TimeRecord::Table
  end

  it "can return an I18n-scope" do
    expect(subject.i18n_scope("time_records")).to eq "fp2020.time_records"
  end

  it "returns only existing classes" do
    expect(described_class.domain_classes("Nonexistent::Thing")).to eq([])
  end

  it "logs skips for missing class paths" do
    messages = []
    allow(Rails.logger).to receive(:debug) do |*args, &blk|
      messages << (args.first || blk&.call)
    end

    described_class.domain_classes("Nonexistent::Thing")

    expect(messages.join("\n"))
      .to include("Class skip:", "Nonexistent::Thing", "not found")
  end

  context "can determine the correct period" do
    it "for 2014 and earlier, it is 2015" do
      expect(described_class.new(2014).determine).to be 2015
    end

    it "for 2015, it is 2015" do
      expect(described_class.new(2015).determine).to be 2015
    end

    it "for 2016, it is 2015" do
      expect(described_class.new(2016).determine).to be 2015
    end

    it "for 2017, it is 2015" do
      expect(described_class.new(2017).determine).to be 2015
    end

    it "for 2018, it is 2015" do
      expect(described_class.new(2018).determine).to be 2015
    end

    it "for 2019, it is 2015" do
      expect(described_class.new(2019).determine).to be 2015
    end

    it "for 2020, it is 2020" do
      expect(described_class.new(2020).determine).to be 2020
    end

    it "for 2021, it is 2020" do
      expect(described_class.new(2021).determine).to be 2020
    end

    it "for 2022, it is 2022" do
      expect(described_class.new(2022).determine).to be 2022
    end

    it "for 2023 and later, it is 2022" do
      expect(described_class.new(2023).determine).to be 2022
    end

    it "for 2024, it is 2024" do
      expect(described_class.new(2024).determine).to be 2024
    end

    it "for 2025 and later, it is 2024" do
      expect(described_class.new(2025).determine).to be 2024
    end
  end

  # if this grows too much, we might need to rethink this. Maybe optimize
  # lookups, lazily load older code or discontinue older periods. Symptoms
  # could be a slow app-startup, slow exports or the feeling of
  # unmaintainability. At 4 periods, we should track some baseline numbers
  # here, maybe add some performance-specs.
  context "is a sensible solution, it" do
    it "covers all periods" do
      expect(described_class::KNOWN_BASE_YEARS).to have(4).items
    end
  end
end
