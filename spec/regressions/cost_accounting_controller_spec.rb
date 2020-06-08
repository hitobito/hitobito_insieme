# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CostAccountingController, type: :controller  do

  render_views

  let(:year) { 2014 }
  let(:group) { groups(:be) }
  let(:report) { 'lohnaufwand' }

  before { sign_in(people(:top_leader)) }

  context 'for no records' do

    context 'GET index' do
      it 'renders' do
        get :index, params: { id: group.id, year: year }
        is_expected.to render_template('index')
      end
    end

    context 'GET edit' do
      it 'renders' do
        get :edit, params: { id: group.id, year: year, report: report }
        is_expected.to render_template('edit')
        expect(assigns(:entry)).to be_new_record
      end
    end

    context 'PUT update' do
      context 'in regionalverein' do
        it 'updates values' do
          expect do
            put :update, params: {
                           id: group.id,
                           year: year,
                           report: report,
                           cost_accounting_record: {
                             aufwand_ertrag_fibu: 2000,
                             abgrenzung_fibu: nil }
                         }
          end.to change { CostAccountingRecord.count }.by(1)

          is_expected.to redirect_to(cost_accounting_group_path(group, year: year))

          r = CostAccountingRecord.where(group_id: group.id, year: year, report: report).first
          expect(r.aufwand_ertrag_fibu).to eq(2000)
          expect(r.abgrenzung_fibu).to be_nil
        end

        it 'may only update editable fields' do
          expect do
            put :update, params: {
                           id: group.id,
                           year: year,
                           report: report,
                           cost_accounting_record: {
                             aufwand_ertrag_fibu: 2000,
                             abgrenzung_dachorganisation: 100,
                             tageskurse: 20,
                             verwaltung: 30 }
                         }
          end.to change { CostAccountingRecord.count }.by(1)

          is_expected.to redirect_to(cost_accounting_group_path(group, year: year))

          r = CostAccountingRecord.where(group_id: group.id, year: year, report: report).first
          expect(r.aufwand_ertrag_fibu).to eq(2000)
          expect(r.abgrenzung_dachorganisation).to be_nil
          expect(r.tageskurse).to be_nil
          expect(r.verwaltung).to be_nil
        end

        context 'frozen year' do
          before { GlobalValue.first.update!(reporting_frozen_until_year: 2015) }
          after { GlobalValue.clear_cache }

          it 'may not update values' do
            expect do
              put :update, params: {
                    id: group.id,
                    year: 2015,
                    report: report,
                    cost_accounting_record: {
                      aufwand_ertrag_fibu: 2000,
                      abgrenzung_fibu: nil }
                  }
            end.not_to change { CostAccountingRecord.count }
          end
        end
      end

      context 'in dachverein' do
        let(:group) { groups(:dachverein) }

        it 'may only update editable fields' do
          expect do
            put :update, params: {
                           id: group.id,
                           year: year,
                           report: report,
                           cost_accounting_record: {
                             aufwand_ertrag_fibu: 2000,
                             abgrenzung_fibu: 50,
                             abgrenzung_dachorganisation: 100,
                             tageskurse: 20,
                             verwaltung: 30 }
                         }
          end.to change { CostAccountingRecord.count }.by(1)

          is_expected.to redirect_to(cost_accounting_group_path(group, year: year))

          r = CostAccountingRecord.where(group_id: group.id, year: year, report: report).first
          expect(r.aufwand_ertrag_fibu).to eq(2000)
          expect(r.abgrenzung_fibu).to eq(50)
          expect(r.abgrenzung_dachorganisation).to eq(100)
          expect(r.tageskurse).to be_nil
          expect(r.verwaltung).to be_nil
        end
      end

    end
  end

  context 'for existing record' do

    before do
      CostAccountingRecord.create!(group_id: group.id,
                                   year: year,
                                   report: report,
                                   aufwand_ertrag_fibu: 1050,
                                   abgrenzung_fibu: 50)
    end

    context 'GET index' do
      it 'renders' do
        get :index, params: { id: group.id, year: year }
        is_expected.to render_template('index')
      end
    end

    context 'GET edit' do
      it 'renders' do
        get :edit, params: { id: group.id, year: year, report: report }
        is_expected.to render_template('edit')
        expect(assigns(:entry)).to be_persisted
      end
    end

    context 'PUT update' do
      it 'updates values' do
        expect do
          put :update, params: {
                         id: group.id,
                         year: year,
                         report: report,
                         cost_accounting_record: {
                           aufwand_ertrag_fibu: 2000,
                           abgrenzung_fibu: nil }
                       }
        end.not_to change { CostAccountingRecord.count }

        is_expected.to redirect_to(cost_accounting_group_path(group, year: year))

        r = CostAccountingRecord.where(group_id: group.id, year: year, report: report).first
        expect(r.aufwand_ertrag_fibu).to eq(2000)
        expect(r.abgrenzung_fibu).to be_nil
      end
    end
  end

end
