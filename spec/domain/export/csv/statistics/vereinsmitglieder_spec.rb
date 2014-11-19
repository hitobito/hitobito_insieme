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
      (subject.keys & counted).size.should eq counted.size
    end

    it 'contains translated attribute labels' do
      subject[:zip_code].should eq 'PLZ'
      subject[:canton].should eq 'Kanton'
    end
  end

  context '#list' do
    subject { csv.list }

    it 'has one item per regional verein' do
      subject.size.should eq 3
    end

    it 'contains the correct values' do
      row = subject.first
      row[:name].should eq 'Biel-Seeland'
      row[Group::Aktivmitglieder::Aktivmitglied].should eq 1
      row[Group::Aktivmitglieder::AktivmitgliedOhneAbo].should eq 0
    end
  end

end