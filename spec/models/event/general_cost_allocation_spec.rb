# encoding: utf-8
# == Schema Information
#
# Table name: event_general_cost_allocations
#
#  id                         :integer          not null, primary key
#  group_id                   :integer          not null
#  year                       :integer          not null
#  general_costs_blockkurs    :decimal(12, 2)
#  general_costs_tageskurs    :decimal(12, 2)
#  general_costs_semesterkurs :decimal(12, 2)
#  created_at                 :datetime
#  updated_at                 :datetime
#


#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


require 'spec_helper'

describe Event::GeneralCostAllocation do

  context 'validations' do
    it 'may be attached to regionalverein' do
      a = Event::GeneralCostAllocation.new(group: groups(:be), year: 2014)
      a.should be_valid
    end

    it 'may not be attached to active' do
      a = Event::GeneralCostAllocation.new(group: groups(:aktiv), year: 2014)
      a.should_not be_valid
    end
  end

end
