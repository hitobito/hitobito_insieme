#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Event::GeneralCostAllocationsController, type: :controller do
  render_views

  let(:group) { groups(:dachverein) }

  before { sign_in(people(:top_leader)) }

  context "#show" do
    it "redirects to edit if format is html" do
      get :show, params: {group_id: group.id, year: 2014}
      is_expected.to redirect_to(edit_general_cost_allocation_group_events_path(group, 2014))
    end

    it "renders csv" do
      get :show, params: {group_id: group.id, year: 2014}, format: :csv
      csv = response.body
      expect(csv).to match(Regexp.new("\\A#{Export::Csv::UTF8_BOM};"))
      expect(csv).to match(Regexp.new("^#{Export::Csv::UTF8_BOM};Total direkte Kosten;Total Gemeinkosten;Gemeinkostenzuschlag$"))
    end
  end

  context "#edit" do
    it "builds new time_record based on group and year" do
      get :edit, params: {group_id: group.id, year: 2014}
      expect(response.status).to eq(200)

      expect(assigns(:entry)).not_to be_persisted
      expect(assigns(:entry).group).to eq group
      expect(assigns(:entry).year).to eq 2014
    end

    it "reuses existing time_record based on group and year" do
      record = Event::GeneralCostAllocation.create!(group: group, year: 2014)
      get :edit, params: {group_id: group.id, year: 2014}
      expect(assigns(:entry)).to eq record
      expect(assigns(:entry)).to be_persisted
    end
  end

  context "#update" do
    let(:attrs) do
      {general_costs_blockkurse: 300,
       general_costs_tageskurse: 400,
       general_costs_semesterkurse: 500,
       general_costs_treffpunkte: 600}
    end

    it "assigns all permitted params" do
      expect do
        expect do
          put :update, params: {group_id: group.id, year: 2014, event_general_cost_allocation: attrs}
        end.to change { Event::GeneralCostAllocation.count }.by(1)
      end.to change { Delayed::Job.count }.by(1)

      is_expected.to redirect_to(edit_general_cost_allocation_group_events_path(group, 2014))

      r = Event::GeneralCostAllocation.where(group_id: group.id, year: 2014).first
      expect(r.general_costs_blockkurse).to eq 300
      expect(r.general_costs_tageskurse).to eq 400
      expect(r.general_costs_semesterkurse).to eq 500
      expect(r.general_costs_treffpunkte).to eq 600
    end
  end
end
