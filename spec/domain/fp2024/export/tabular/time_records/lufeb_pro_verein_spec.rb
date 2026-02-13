# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Fp2024::Export::Tabular::TimeRecords::LufebProVerein do
  include Featureperioden::Domain

  let(:year) { 2024 }
  subject { described_class.new(data) }

  let(:data) do
    lpv = Fp2024::TimeRecord::LufebProVerein.new(year)
    verein_ids = lpv.vereine.map(&:id)

    lpv.instance_variable_set(:@lufeb_data, {
      verein_ids[0] => Fp2024::TimeRecord::LufebProVerein::Data.new(1, 2, 3, 4, 5),
      verein_ids[1] => Fp2024::TimeRecord::LufebProVerein::Data.new(2, 4, 6, 8, 9),
      verein_ids[2] => Fp2024::TimeRecord::LufebProVerein::Data.new(Array.new(5) { 0 }),
      verein_ids[3] => Fp2024::TimeRecord::LufebProVerein::Data.new(Array.new(5) { 0 })
    })

    lpv
  end

  it "has labels" do
    expected = ["Gruppe/Feldname", ""]

    expect(subject.labels).to match_array expected
    expect(subject.labels).to eq expected
  end

  it "has all the calculated values" do
    rows = subject.data_rows.take(10)

    expect(rows[0]).to be_all nil
    expect(rows[1]).to eq ["insieme Schweiz", nil]
    expect(rows[2]).to eq ["Allgemeine Medien & Öffentlichkeitsarbeit", 1]
    expect(rows[3]).to eq ["Themenspezifische Grundlagenarbeit", 11]
    expect(rows[4]).to eq ["Förderung der Selbsthilfe", 3]
    expect(rows[5]).to be_all nil
    expect(rows[6]).to eq ["Kanton Bern", nil]
    expect(rows[7]).to eq ["Allgemeine Medien & Öffentlichkeitsarbeit", 2]
    expect(rows[8]).to eq ["Themenspezifische Grundlagenarbeit", 21]
    expect(rows[9]).to eq ["Förderung der Selbsthilfe", 6]
  end

  context "adds grundlagenarbeit to specific, it" do
    let(:group) { groups(:seeland) }

    subject(:lufeb_verein_data) do
      # Struct.new(:general, :specific, :promoting, :lufeb_grundlagen, :kurse_grundlagen)
      fp_class("TimeRecord::LufebProVerein::Data").new(nil, 30, nil, 10, 20)
    end

    it "takes data from the lufeb-for-verein-data" do
      expect(lufeb_verein_data.specific.to_f).to eq 30
      expect(lufeb_verein_data.lufeb_grundlagen.to_f).to eq 10
      expect(lufeb_verein_data.kurse_grundlagen.to_f).to eq 20
    end

    it "matches the actual implementation result" do
      # collaborators
      stats = double("LUFEB pro Verein-stats")

      # return-values from collbarators
      allow(stats).to receive(:year).and_return(year) # from let above
      expect(stats).to receive(:lufeb_data_for).with(group.id).and_return(lufeb_verein_data)

      # execute
      result = described_class.new(stats)
        .send(:specific_with_grundlagen, group)

      expect(result).to be_within(0.001).of(60)
    end
  end
end
