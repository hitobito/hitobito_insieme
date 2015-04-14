# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CostAccountingController do

  before { sign_in(people(:top_leader)) }

  it 'raises 404 for unsupported group type' do
    expect do
      get :index, id: groups(:aktiv).id
    end.to raise_error(CanCan::AccessDenied)
  end

  context 'GET index' do
    context 'cost accounting csv export' do
      let(:group) { groups(:be) }
      let(:year) { 2014 }

      before { get :index, id: group, year: year, format: :csv }

      it 'exports table' do
        expect(@response.body).to match(/Report;Kontengruppe;Aufwand \/ Ertrag FIBU/)
        expect(@response.body).to match(/Total Aufwand\/Kosten/)
      end

      context 'no vid and bsv_number present' do
        it 'should use a filename containing only group name and year' do
          expect(@response['Content-Disposition']).to match(
            /filename="cost_accounting_kanton-bern_2014\.csv"/)
        end
      end

      context 'all group infos present' do
        let(:group) do
          group = groups(:be)
          group.update(vid: 12, bsv_number: 3456)
          group
        end

        it 'should use a filename containing vid, bsv_number, group name and year' do
          expect(@response['Content-Disposition']).to match(
            /filename="cost_accounting_vid12_bsv3456_kanton-bern_2014\.csv"/)
        end
      end
    end
  end

end
