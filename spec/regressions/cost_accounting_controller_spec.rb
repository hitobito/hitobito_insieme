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
        get :index, id: group.id, year: year
        should render_template('index')
      end
    end

    context 'GET edit' do
      it 'renders' do
        get :edit, id: group.id, year: year, report: report
        should render_template('edit')
        assigns(:record).should be_new_record
      end
    end

    context 'PUT update' do
      context 'in regionalverein' do
        it 'updates values' do
          expect do
            put :update, id: group.id,
                         year: year,
                         report: report,
                         cost_accounting_record: {
                           aufwand_ertrag_fibu: 2000,
                           abgrenzung_fibu: nil }
          end.to change { CostAccountingRecord.count }.by(1)

          should redirect_to(cost_accounting_group_path(group, year: year))

          r = CostAccountingRecord.where(group_id: group.id, year: year, report: report).first
          r.aufwand_ertrag_fibu.should eq(2000)
          r.abgrenzung_fibu.should be_nil
        end

        it 'may only update editable fields' do
          expect do
            put :update, id: group.id,
                         year: year,
                         report: report,
                         cost_accounting_record: {
                           aufwand_ertrag_fibu: 2000,
                           abgrenzung_dachorganisation: 100,
                           tageskurse: 20,
                           verwaltung: 30 }
          end.to change { CostAccountingRecord.count }.by(1)

          should redirect_to(cost_accounting_group_path(group, year: year))

          r = CostAccountingRecord.where(group_id: group.id, year: year, report: report).first
          r.aufwand_ertrag_fibu.should eq(2000)
          r.abgrenzung_dachorganisation.should be_nil
          r.tageskurse.should be_nil
          r.verwaltung.should be_nil
        end
      end

      context 'in dachverein' do
        let(:group) { groups(:dachverein) }

        it 'may only update editable fields' do
          expect do
            put :update, id: group.id,
                         year: year,
                         report: report,
                         cost_accounting_record: {
                           aufwand_ertrag_fibu: 2000,
                           abgrenzung_fibu: 50,
                           abgrenzung_dachorganisation: 100,
                           tageskurse: 20,
                           verwaltung: 30 }
          end.to change { CostAccountingRecord.count }.by(1)

          should redirect_to(cost_accounting_group_path(group, year: year))

          r = CostAccountingRecord.where(group_id: group.id, year: year, report: report).first
          r.aufwand_ertrag_fibu.should eq(2000)
          r.abgrenzung_fibu.should eq(50)
          r.abgrenzung_dachorganisation.should eq(100)
          r.tageskurse.should be_nil
          r.verwaltung.should be_nil
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
        get :index, id: group.id, year: year
        should render_template('index')
      end
    end

    context 'GET edit' do
      it 'renders' do
        get :edit, id: group.id, year: year, report: report
        should render_template('edit')
        assigns(:record).should be_persisted
      end
    end

    context 'PUT update' do
      it 'updates values' do
        expect do
          put :update, id: group.id,
                       year: year,
                       report: report,
                       cost_accounting_record: {
                         aufwand_ertrag_fibu: 2000,
                         abgrenzung_fibu: nil }
        end.not_to change { CostAccountingRecord.count }

        should redirect_to(cost_accounting_group_path(group, year: year))

        r = CostAccountingRecord.where(group_id: group.id, year: year, report: report).first
        r.aufwand_ertrag_fibu.should eq(2000)
        r.abgrenzung_fibu.should be_nil
      end
    end
  end

end
