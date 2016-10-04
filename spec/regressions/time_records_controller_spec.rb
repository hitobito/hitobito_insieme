# encoding: utf-8

#  Copyright (c) 2016, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe TimeRecordsController, type: :controller  do

  render_views

  before { sign_in(people(:top_leader)) }

  context 'GET#index' do
    it 'raises 404 for unsupported group type' do
      expect do
        get :index, id: groups(:aktiv).id
      end.to raise_error(CanCan::AccessDenied)
    end

    it 'redirects to base information' do
      get :index, id: groups(:dachverein).id, year: 2014
      is_expected.to redirect_to(time_record_base_information_group_path(groups(:dachverein), 2014))
    end

    it 'exports csv' do
      get :index, id: groups(:dachverein).id, format: :csv
      csv = response.body
      expect(csv).to match(/\A;Zeiterfassung Angestellte;Zeiterfassung Ehrenamtliche mit Leistungsnachweis;Zeiterfassung Ehrenamtliche ohne Leistungsnachweis/)
      expect(csv).to match(/^Art\. 74 betreffend in 100% Stellen;;;$/)
    end
  end

  context 'GET#exports' do
    it 'renders buttons' do
      get :exports, id: groups(:dachverein).id, year: 2014
      is_expected.to render_template('exports')
    end
  end

end
