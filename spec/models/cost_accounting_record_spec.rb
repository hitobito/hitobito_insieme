# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CostAccountingRecord do

  let(:group) { groups(:be) }

  context 'validation' do
    it 'is fine with empty fields' do
      r = CostAccountingRecord.new(group: group, year: 2014, report: 'lohnaufwand')
      r.should be_valid
    end

    it 'fails for invalid report' do
      r = CostAccountingRecord.new(group: group, year: 2014, report: 'foo')
      r.should_not be_valid
    end

    it 'fails for invalid group' do
      r = CostAccountingRecord.new(group: groups(:passiv), year: 2014, report: 'lohnaufwand')
      r.should_not be_valid
    end
  end

end
