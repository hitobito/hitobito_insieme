# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CapitalSubstrateController do
  let(:group) { groups(:dachverein) }

  it 'raises 404 for unsupported group type' do
    sign_in(people(:top_leader))
    expect do
      get :edit, id: groups(:kommission74).id, year: 2014
    end.to raise_error(CanCan::AccessDenied)
  end

  context 'authorization' do
    it 'top leader is allowed to update dachverein' do
      sign_in(people(:top_leader))
      get :edit, id: group.id, year: 2014
      expect(response).to be_ok
    end

    it 'regio leader is not allowed to update dachverein' do
      expect do
        sign_in(people(:regio_leader))
        get :edit, id: group.id, year: 2014
      end.to raise_error(CanCan::AccessDenied)
    end
  end

  context '#edit' do
    before { sign_in(people(:top_leader)) }

    it 'builds new capital_substrate based on group and year' do
      get :edit, id: group.id, year: 2014
      expect(response.status).to eq(200)

      expect(assigns(:record)).not_to be_persisted
      expect(assigns(:record).group).to eq group
      expect(assigns(:record).year).to eq 2014
    end

    it 'reuses existing capital_substrate based on group and year' do
      record = CapitalSubstrate.create!(group: group, year: 2014)
      get :edit, id: group.id, year: 2014
      expect(assigns(:record)).to eq record
      expect(assigns(:record)).to be_persisted
    end

    it 'provides the report' do
      get :edit, id: group.id, year: 2014
      expect(response.status).to eq(200)

      expect(@controller.report).to be_a(TimeRecord::Report::CapitalSubstrate)
      expect(@controller.report.table).to be
    end
  end

  context '#update' do
    before { sign_in(people(:top_leader)) }

    let(:attrs) do
      {
        organization_capital: 10,
        fund_building: 10
      }
    end

    it 'assigns all permitted params' do
      expect do
        put :update, id: group.id, year: 2014, capital_substrate: attrs
      end.to change { CapitalSubstrate.count }.by(1)

      expect(assigns(:record).organization_capital).to eq(10)
      expect(assigns(:record).fund_building).to eq(10)
    end
  end
end
