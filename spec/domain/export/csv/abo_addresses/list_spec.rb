# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'
require 'csv'

describe Export::Csv::AboAddresses::List do

  let(:people_list) { AboAddresses::Query.new(true, 'de').people }

  let(:list) { described_class.new(people_list) }

  context '#attribute_labels' do
    subject { list.attribute_labels }

    it 'contains hard-coded attribute labels' do
      subject[:number].should eq 'Kd.Nr.'
      subject[:name].should eq 'Vorname und Name'
      subject[:address].should eq 'Adresse'
    end
  end

  context '#to_csv' do
    subject { [].tap { |csv| list.to_csv(csv) } }

    it 'has one item per person' do
      subject.size.should eq 2
    end

    it 'contains the correct values' do
      people(:regio_aktiv).update!(first_name: 'Hans',
                                   last_name: 'Muster',
                                   company_name: 'Firma',
                                   address: 'Eigerplatz 4',
                                   zip_code: 3000,
                                   town: 'Bern',
                                   country: 'CH',
                                   number: 123)
      subject.last.should eq [123,
                              'Hans Muster',
                              'Firma',
                              nil,
                              'Eigerplatz 4',
                              '3000 Bern',
                              nil]
    end
  end

end