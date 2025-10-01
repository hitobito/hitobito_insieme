# frozen_string_literal: true

require "spec_helper"

RSpec.describe PolicyRegistry do
  describe ".for" do
    it "returns V10 for 2024" do
      policy = described_class.for(year: 2024)
      expect(policy).to be_a(Policies::Fsio2428::V10)
      expect(policy.include_grundlagen_hours?).to eq(true)
    end

    it "returns V11 for 2025" do
      policy = described_class.for(year: 2025)
      expect(policy).to be_a(Policies::Fsio2428::V11)
      expect(policy.include_grundlagen_hours?).to eq(false)
    end
  end
end
