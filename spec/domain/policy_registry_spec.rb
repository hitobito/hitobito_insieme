# frozen_string_literal: true
require "spec_helper"

RSpec.describe PolicyRegistry do
  describe ".for" do
    it "returns V10 for 2024" do
      policy = described_class.for(year: 2024)
      expect(policy).to be_a(Policies::Fsio2428::V10)
      expect(policy.include_grundlagen_hours?).to eq(true)
    end

    it "currently returns V10 for 2025 (will change in next PR)" do
      policy = described_class.for(year: 2025)
      expect(policy).to be_a(Policies::Fsio2428::V10) # update to V11 in next PR
      expect(policy.include_grundlagen_hours?).to eq(true)
    end
  end
end
