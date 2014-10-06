# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CostAccountingParameter do

  describe '.previous' do
    subject { CostAccountingParameter.previous }
    let(:now) { Time.zone.now }

    it 'is nil when no records exist' do
      should be_nil
    end

    it 'does not return parameter from future year' do
      create(now.year + 1)
      should be_nil
    end

    it 'does not return parameter from same year' do
      create(now.year)
      should be_nil
    end

    it 'does return last parameter from past years' do
      last = create(now.year - 1)
      create(now.year - 2)
      should eq last
    end

  end

  describe 'validations' do
    subject { CostAccountingParameter.new }

    it 'validates presence of year, kat1_bk and kat2_tk' do
      should have(1).errors_on(:year)
      should have(1).errors_on(:kat1_bk)
      should have(1).errors_on(:kat2_tk)
    end

    it 'validates uniqneness of year' do
      create(2014)
      CostAccountingParameter.new(year: 2014).should have(1).error_on(:year)
    end

  end

  def create(year)
    CostAccountingParameter.create!(year: year, kat1_bk: 1, kat2_tk: 2)
  end
end
