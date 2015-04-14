# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'
require 'csv'

describe Export::Csv::Statistics::Vereinsmitglieder do

  let(:vereinsmitglieder) { Statistics::Vereinsmitglieder.new }

  let(:csv) { described_class.new(vereinsmitglieder) }

  context '#attribute_labels' do
    subject { csv.attribute_labels }

    it 'contains all counted roles' do
      counted = Statistics::Vereinsmitglieder::COUNTED_ROLES
      expect((subject.keys & counted).size).to eq counted.size
    end

    it 'contains translated attribute labels' do
      expect(subject[:zip_code]).to eq 'PLZ'
      expect(subject[:canton]).to eq 'Kanton'
    end
  end

  context '#list' do
    subject { csv.list }

    it 'has one item per regional verein' do
      expect(subject.size).to eq 3
    end

    it 'contains the correct values' do
      row = subject.first
      expect(row[:name]).to eq 'Biel-Seeland'
      expect(row[Group::Aktivmitglieder::Aktivmitglied]).to eq 1
      expect(row[Group::Aktivmitglieder::AktivmitgliedOhneAbo]).to eq 0
    end
  end

end