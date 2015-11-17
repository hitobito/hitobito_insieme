# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe StatisticsController, type: :controller  do

  render_views

  before { sign_in(people(:top_leader)) }

  it 'raises 404 for unsupported group type' do
    expect do
      get :show, id: groups(:aktiv).id
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'shows stats' do
    get :show, id: groups(:dachverein).id
    is_expected.to render_template('show')
  end

  it 'exports csv' do
    get :show, id: groups(:dachverein).id, format: :csv
    csv = response.body
    expect(csv).to match(/\AVID;Name;Aktivmitglieder;Aktivmitglieder ohne Abo;/)
    expect(csv).to match(/^;Biel-Seeland;1;0;0;0;0;0;0;;;;;Bern$/)
  end

end
