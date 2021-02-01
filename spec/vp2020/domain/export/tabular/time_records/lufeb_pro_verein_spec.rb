# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Vp2020::Export::Tabular::TimeRecords::LufebProVerein do
  include Vertragsperioden::Domain

  let(:year) { 2020 }
  subject { described_class.new(data) }

  let(:data) do
    lpv = Vp2020::TimeRecord::LufebProVerein.new(year)
    verein_ids = lpv.vereine.map(&:id)

    lpv.instance_variable_set('@lufeb_data', {
      verein_ids[0] => Vp2020::TimeRecord::LufebProVerein::Data.new(1, 2, 3, 4, 5),
      verein_ids[1] => Vp2020::TimeRecord::LufebProVerein::Data.new(2, 4, 6, 8, 9),
      verein_ids[2] => Vp2020::TimeRecord::LufebProVerein::Data.new(Array.new(5) {0}),
      verein_ids[3] => Vp2020::TimeRecord::LufebProVerein::Data.new(Array.new(5) {0})
    })

    lpv
  end

  it 'has labels' do
    expected = ['Gruppe/Feldname', '']

    expect(subject.labels).to match_array expected
    expect(subject.labels).to eq expected
  end

  it 'has all the calculated values' do
    rows = subject.data_rows.take(10)

    expect(rows[0]).to be_all nil
    expect(rows[1]).to eq ['insieme Schweiz',                           nil]
    expect(rows[2]).to eq ['Allgemeine Medien & Öffentlichkeitsarbeit',   1]
    expect(rows[3]).to eq ['Themenspezifische Grundlagenarbeit',         11]
    expect(rows[4]).to eq ['Förderung der Selbsthilfe',                   3]
    expect(rows[5]).to be_all nil
    expect(rows[6]).to eq ['Kanton Bern',                               nil]
    expect(rows[7]).to eq ['Allgemeine Medien & Öffentlichkeitsarbeit',   2]
    expect(rows[8]).to eq ['Themenspezifische Grundlagenarbeit',         21]
    expect(rows[9]).to eq ['Förderung der Selbsthilfe',                   6]
  end

  context 'adds a part of a grundlagenarbeit to specific, it' do
    let(:group) { groups(:seeland) }

    subject(:lufeb_verein_data) do
      # Struct.new(:general, :specific, :promoting, :lufeb_grundlagen, :kurse_grundlagen)
      vp_class('TimeRecord::LufebProVerein::Data').new(nil, 30, nil, 10, 20)
    end

    it 'fetches various parts from the kostenrechnung and sums them' do
      kostenrechnung = vp_class('CostAccounting::Table').new(group, year)

      expect(kostenrechnung).to receive(:value_of).with('total_personalaufwand', 'jahreskurse').and_return(1495.24.to_d)
      expect(kostenrechnung).to receive(:value_of).with('total_personalaufwand', 'blockkurse').and_return(4990.48.to_d)
      expect(kostenrechnung).to receive(:value_of).with('total_personalaufwand', 'tageskurse').and_return(1497.62.to_d)
      expect(kostenrechnung).to receive(:value_of).with('total_personalaufwand', 'treffpunkte').and_return(3244.05.to_d)

      total = [
        kostenrechnung.value_of('total_personalaufwand', 'jahreskurse'),
        kostenrechnung.value_of('total_personalaufwand', 'blockkurse'),
        kostenrechnung.value_of('total_personalaufwand', 'tageskurse'),
        kostenrechnung.value_of('total_personalaufwand', 'treffpunkte'),
      ].map(&:to_f).sum

      expect(total).to be_within(0.01).of(11227.39)
    end

    it 'derives the anteil from the kostenrechnung' do
      anteil = ((11227.39.to_f - 3244.05.to_f) / 11227.39.to_f)

      expect(anteil).to be_within(0.001).of(0.711)
    end

    it 'takes data from the lufeb-for-verein-data' do
      expect(lufeb_verein_data.specific.to_f).to eq 30
      expect(lufeb_verein_data.lufeb_grundlagen.to_f).to eq 10
      expect(lufeb_verein_data.kurse_grundlagen.to_f).to eq 20
    end

    it 'adds the anteil to the specifics' do
      result = 30 + 10 + (20 * 0.711)

      expect(result).to be_within(0.001).of(54.221)
    end

    it 'matches the actual implementation result' do
      # collaborators
      kostenrechnung = double("CostAccounting-Table")
      stats = double('LUFEB pro Verein-stats')

      # return-values from collbarators
      allow(stats).to receive(:year).and_return(year) # from let above
      expect(stats).to receive(:lufeb_data_for).with(group.id).and_return(lufeb_verein_data)

      expect(kostenrechnung).to receive(:value_of).with('total_personalaufwand', 'jahreskurse').and_return(1495.24.to_d)
      expect(kostenrechnung).to receive(:value_of).with('total_personalaufwand', 'blockkurse').and_return(4990.48.to_d)
      expect(kostenrechnung).to receive(:value_of).with('total_personalaufwand', 'tageskurse').and_return(1497.62.to_d)
      expect(kostenrechnung).to receive(:value_of).with('total_personalaufwand', 'treffpunkte').and_return(3244.05.to_d)

      # wire collaborators together
      expect(vp_class('CostAccounting::Table')).to receive(:new).with(group, year).and_return(kostenrechnung)

      # execute
      result = described_class.new(stats)
                              .send(:specific_with_grundlagen, group)

      expect(result).to be_within(0.001).of(54.221)
    end
  end
end
