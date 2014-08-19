# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Person do

  context 'canton_value' do

    it 'is blank for nil value' do
      Person.new.canton_value.should be_blank
    end

    it 'is blank for blank value' do
      Person.new(canton: '').canton_value.should be_blank
    end

    it 'is locale specific value for valid key' do
      Person.new(canton: 'be').canton_value.should eq 'Bern'
    end
  end

end
