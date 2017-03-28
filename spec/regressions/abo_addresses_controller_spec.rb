# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe AboAddressesController, type: :controller  do

  render_views

  before { sign_in(people(:top_leader)) }

  it 'exports csv' do
    get :index, id: groups(:dachverein).id, language: 'de', country: 'ch', format: :csv
    csv = response.body
    expect(csv).to match(/\AKd.Nr.;Vorname und Name;Firma;Adresse 1;Adresse 2;Adresse 3;PLZ und Ort;Land$/)
    expect(csv).to match(/^;Active Person;;;;;"";$/)
  end

  it 'raises 404 for unsupported group type' do
    expect do
      get :index, id: groups(:aktiv).id
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'raises not allowed without required permissions' do
    controller = Fabricate(Group::Dachverein::External.name.to_sym,
                           group: groups(:dachverein)).person
    sign_in(controller)
    expect do
      get :index, id: groups(:dachverein).id
    end.to raise_error(CanCan::AccessDenied)
  end
end
