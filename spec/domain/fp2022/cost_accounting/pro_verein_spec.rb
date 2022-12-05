# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Fp2022::CostAccounting::ProVerein do
  let(:year) { 2022 }
  subject { described_class.new(year) }

  let(:group) { groups(:dachverein) }

  it 'knows a list of groups to export' do
    expected = [
      'insieme Schweiz',
      'Kanton Bern',
      'Biel-Seeland',
      'Freiburg'
    ]

    expect(subject.vereine.map(&:name)).to match_array expected
    expect(subject.vereine.map(&:name)).to eq expected
  end


  it 'has a structured data-object for all groups' do
    list = subject.vereine.map { |verein| subject.data_for(verein) }

    expect(list).to be_all Hash
    expect(list.first.values).to be_all described_class::CostAccountingRow
  end

  context 'has correct data' do
    let(:data) { subject.data_for(group) }

    it 'judging by the hash-keys' do
      expected = [
        :personalaufwand,
        :honorare,
        :sachaufwand,
        :aufwand,
        :gemeinkosten,
        :umlagen,
        :total_aufwand,
        :leistungen,
        :beitraege_iv,
        :sonstige_beitraege,
        :spenden_zweckgebunden,
        :spenden_nicht_zweckgebunden,
      ]

      expected.each do |key|
        expect(data).to have_key key
      end
    end

    it 'for gemeinkosten' do
      expected = [nil, nil, nil, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      actual = data[:gemeinkosten].to_a

      expect(actual).to match_array expected
      expect(actual).to eq expected
    end

    it 'for indirekte spenden' do
      expected = [0.0, nil, nil, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
      actual = data[:spenden_nicht_zweckgebunden].to_a

      expect(actual).to match_array expected
      expect(actual).to eq expected
    end
  end

  describe Fp2022::CostAccounting::ProVerein::CostAccountingRow do
    subject(:empty_row) { described_class.empty_row }
    subject(:row) { described_class.new(*(1..10).to_a) }

    it 'can be empty' do
      expect(described_class.empty_row).to be_a described_class
    end

    it 'can be added together' do
      expect(row).to respond_to(:+)
      expect(row.aufwand_ertrag_fibu).to eq 1

      sum = row + row
      expect(sum).to be_a described_class
      expect(sum.aufwand_ertrag_fibu).to eq 2
    end

    it 'knows its members' do
      expected = [
        :aufwand_ertrag_fibu,
        :abgrenzung,
        :klr,
        :gemeinkosten,
        :sozialberatung,
        :bauberatung,
        :rechtsberatung,
        :vermittlung,
        :wohnbegleitung,
        :media,
        :jahreskurse,
        :blockkurse,
        :tageskurse,
        :treffpunkte,
        :lufeb
      ]

      expect(row.members).to match_array expected
      expect(row.members).to eq expected
    end

    it 'can remove values from a value' do
      expect(row.gemeinkosten).to eq 3
      expect(row.sozialberatung).to eq 4

      nulled_row = row.nullify(:gemeinkosten)
      expect(nulled_row).to be_a described_class
      expect(nulled_row.gemeinkosten).to eq nil
      expect(nulled_row.sozialberatung).to eq 4
    end
  end
end
