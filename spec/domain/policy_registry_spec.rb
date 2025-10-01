# frozen_string_literal: true

require "spec_helper"

RSpec.describe PolicyRegistry do
  describe ".for" do
    context "2024 (V10)" do
      subject(:policy) { described_class.for(year: 2024) }

      it "returns V10" do
        expect(policy).to be_a(Policies::Fsio2428::V10)
      end

      it "includes Grundlagen hours for all fachkonzepte" do
        %w[freizeit_jugend freizeit_erwachsen sport_jugend sport_erwachsen autonomie_foerderung treffpunkt].each do |fk|
          expect(policy.include_grundlagen_hours_for?(fk)).to eq(true), "expected true for #{fk}"
        end
      end
    end

    context "2025 (V11)" do
      subject(:policy) { described_class.for(year: 2025) }

      it "returns V11" do
        expect(policy).to be_a(Policies::Fsio2428::V11)
      end

      it "includes only for treffpunkt; excludes for courses" do
        expect(policy.include_grundlagen_hours_for?("treffpunkt")).to eq(true)

        %w[freizeit_jugend freizeit_erwachsen sport_jugend sport_erwachsen autonomie_foerderung].each do |fk|
          expect(policy.include_grundlagen_hours_for?(fk)).to eq(false), "expected false for #{fk}"
        end
      end
    end
  end
end
