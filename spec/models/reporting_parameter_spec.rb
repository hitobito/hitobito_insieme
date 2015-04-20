# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: reporting_parameters
#
#  id                                :integer          not null, primary key
#  year                              :integer          not null
#  vollkosten_le_schwelle1_blockkurs :decimal(12, 2)   not null
#  vollkosten_le_schwelle2_blockkurs :decimal(12, 2)   not null
#  vollkosten_le_schwelle1_tageskurs :decimal(12, 2)   default(0.0), not null
#  vollkosten_le_schwelle2_tageskurs :decimal(12, 2)   default(0.0), not null
#  bsv_hours_per_year                :integer          not null
#  capital_substrate_exemption       :decimal(12, 2)   default(200000.0), not null
#

require 'spec_helper'

describe ReportingParameter do

  describe '.current' do
    let(:p2014) { reporting_parameters(:p2014) }
    subject { ReportingParameter.for(2014) }

    it 'does not return parameter from future year' do
      create(p2014.year + 1)
      is_expected.to eq p2014
    end

    it 'does return parameter from same year' do
      is_expected.to eq p2014
    end

    it 'does return last parameter from past years' do
      p2014.destroy
      last = create(p2014.year - 1)
      create(p2014.year - 2)
      is_expected.to eq last
    end

  end

  describe 'validations' do
    subject { ReportingParameter.new }

    it 'validates presence of year, values' do
      is_expected.to have(1).errors_on(:year)
      is_expected.to have(1).errors_on(:vollkosten_le_schwelle1_blockkurs)
      is_expected.to have(1).errors_on(:vollkosten_le_schwelle2_blockkurs)
      is_expected.to have(1).errors_on(:bsv_hours_per_year)
      is_expected.to have(1).errors_on(:capital_substrate_exemption)
    end

    it 'validates uniqneness of year' do
      expect(ReportingParameter.new(year: 2014)).to have(1).error_on(:year)
    end

  end

  def create(year)
    ReportingParameter.create!(year: year,
                               vollkosten_le_schwelle1_blockkurs: 1,
                               vollkosten_le_schwelle2_blockkurs: 2,
                               bsv_hours_per_year: 1900,
                               capital_substrate_exemption: 200_000)
  end
end
