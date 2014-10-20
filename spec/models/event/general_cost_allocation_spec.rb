# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: event_general_cost_allocations
#
#  id                          :integer          not null, primary key
#  group_id                    :integer          not null
#  year                        :integer          not null
#  general_costs_blockkurse    :decimal(12, 2)
#  general_costs_tageskurse    :decimal(12, 2)
#  general_costs_semesterkurse :decimal(12, 2)
#  created_at                  :datetime
#  updated_at                  :datetime
#

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

  context 'with underlying courses' do
    let(:group) { groups(:be) }

    let(:record) do
      Event::GeneralCostAllocation.create!(
        group: group,
        year: 2014,
        general_costs_blockkurse: nil,
        general_costs_tageskurse: 5000,
        general_costs_semesterkurse: 1000)
    end

    before do
      e1 = Fabricate(:course, groups: [ group ], leistungskategorie: 'bk')
      e1.create_course_record!(year: 2014, subventioniert: true, unterkunft: 5000)
      e2 = Fabricate(:course, groups: [ group ], leistungskategorie: 'bk')
      e2.create_course_record!(year: 2014, subventioniert: true, unterkunft: 6000)
      e3 = Fabricate(:course, groups: [ group ], leistungskategorie: 'sk')
      e3.create_course_record!(year: 2014, subventioniert: true, unterkunft: 3000)
      # not subsidized
      e4 = Fabricate(:course, groups: [ group ], leistungskategorie: 'sk')
      e4.create_course_record!(year: 2014, subventioniert: false, unterkunft: 1000)
      # other year
      e5 = Fabricate(:course, groups: [ group ], leistungskategorie: 'tk')
      e5.create_course_record!(year: 2013, subventioniert: true, unterkunft: 4000)
      # other group
      e6 = Fabricate(:course, groups: [ groups(:seeland) ], leistungskategorie: 'bk')
      e6.create_course_record!(year: 2014, subventioniert: true, unterkunft: 2000)
    end

    it 'calculates total_costs bk' do
      record.total_costs('bk').should eq 11000
    end

    it 'calculates total_costs tk' do
      record.total_costs('tk').should eq nil
    end

    it 'calculates total_costs sk' do
      record.total_costs('sk').should eq 3000
    end

    it 'calculates cost allowances blockkurse' do
      record.general_costs_allowance('bk').should eq 0
    end

    it 'calculates cost allowances tageskurse' do
      record.general_costs_allowance('tk').should be nil
    end

    it 'calculates cost allowances semesterkurse' do
      record.general_costs_allowance('sk').should be_within(0.0001).of(0.33333)
    end

  end

end
