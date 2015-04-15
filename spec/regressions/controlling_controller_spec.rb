# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe ControllingController, type: :controller  do

  render_views

  before { sign_in(people(:top_leader)) }

  it 'raises 404 for unsupported group type' do
    expect do
      get :index, id: groups(:aktiv).id
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'shows index' do
    get :index, id: groups(:dachverein).id
    is_expected.to render_template('index')
  end

  context 'GET cost_accounting.csv' do
    before { get :cost_accounting, id: groups(:dachverein), year: 2014, format: :csv }

    it 'exports table' do
      expect(@response.body).to match(/Report;Kontengruppe;Aufwand \/ Ertrag FIBU/)
      expect(@response.body).to match(/Total Aufwand\/Kosten/)
    end
  end

  context 'GET client_statistics.csv' do
    before { get :client_statistics, id: groups(:dachverein), year: 2014, format: :csv }

    it 'exports table' do
      expect(@response.body).to match(/Behinderung \/ Kanton;Blockkurse Anzahl Behinderte \(Personen\);Blockkurse /)
    end
  end

end
