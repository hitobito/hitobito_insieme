# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::GeneralCostAllocationsController, type: :controller do

  render_views

  let(:group) { groups(:dachverein) }

  before { sign_in(people(:top_leader)) }

  context '#edit' do

    it 'builds new time_record based on group and year' do
      get :edit, group_id: group.id, year: 2014
      response.status.should eq(200)

      assigns(:entry).should_not be_persisted
      assigns(:entry).group.should eq group
      assigns(:entry).year.should eq 2014
    end

    it 'reuses existing time_record based on group and year' do
      record = Event::GeneralCostAllocation.create!(group: group, year: 2014)
      get :edit, group_id: group.id, year: 2014
      assigns(:entry).should eq record
      assigns(:entry).should be_persisted
    end
  end

  context '#update' do

    let(:attrs) do
      { general_costs_blockkurs: 300,
        general_costs_tageskurs: 400,
        general_costs_semesterkurs: 500 }
    end

    it 'assigns all permitted params' do
      expect do
        put :update, group_id: group.id, year: 2014, event_general_cost_allocation: attrs
      end.to change { Event::GeneralCostAllocation.count }.by(1)
      should redirect_to(edit_general_cost_allocation_group_events_path(group, 2014))

      r = Event::GeneralCostAllocation.where(group_id: group.id, year: 2014).first
      r.general_costs_blockkurs.should eq 300
      r.general_costs_tageskurs.should eq 400
      r.general_costs_semesterkurs.should eq 500
    end
  end

end