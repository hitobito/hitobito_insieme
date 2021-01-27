# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

describe Vp2020::Export::Tabular::TimeRecords::LufebProVerein do
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
end
