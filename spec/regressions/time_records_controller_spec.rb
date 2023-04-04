# encoding: utf-8

#  Copyright (c) 2016-2020, insieme Schweiz. This file is part of
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
        get :index, params: { id: groups(:aktiv).id }
      end.to raise_error(CanCan::AccessDenied)
    end

    it 'redirects to base information' do
      get :index, params: { id: groups(:dachverein).id, year: 2014 }
      is_expected.to redirect_to(time_record_base_information_group_path(groups(:dachverein), 2014))
    end

    it 'exports csv for 2014' do
      get :index, params: { id: groups(:dachverein).id, year: 2014 }, format: :csv
      csv = response.body
      expect(csv).to match(Regexp.new("\\A#{Export::Csv::UTF8_BOM};Zeiterfassung Angestellte;Zeiterfassung Ehrenamtliche mit Leistungsnachweis;Zeiterfassung Ehrenamtliche ohne Leistungsnachweis"))
      expect(csv).to match(/^Art\. 74 betreffend in 100% Stellen;;;$/)
    end

    it 'exports csv for 2020' do
      get :index, params: { id: groups(:dachverein).id, year: 2020 }, format: :csv
      csv = response.body
      expect(csv).to match(Regexp.new("\\A#{Export::Csv::UTF8_BOM};Zeiterfassung Angestellte;Zeiterfassung Ehrenamtliche mit Leistungsnachweis;Zeiterfassung Ehrenamtliche ohne Leistungsnachweis"))
      expect(csv).to match(/^Art\. 74 betreffend in 100% Stellen;;;$/)
      expect(csv).to match(/^Grundlagenarbeit zu LUFEB/)
    end
  end

end
