# encoding: utf-8

#  Copyright (c) 2012-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe 'CostAccounting::Report::TimeDistributed' do

  let(:year) { 2022 }
  let(:group) { groups(:be) }
  let(:table) { fp_class('CostAccounting::Table').new(group, year) }
  let(:report) { table.reports.fetch('lohnaufwand') }

  context 'with cost accounting record' do

    before do
      CostAccountingRecord.create!(group_id: group.id,
                                   year: year,
                                   report: 'lohnaufwand',
                                   aufwand_ertrag_fibu: 1050,
                                   abgrenzung_fibu: 50)
    end

    context 'with time record' do

      before do
        TimeRecord::EmployeeTime.create!(
          group_id: group.id,
          year: year,
          verwaltung: 50,
          mittelbeschaffung: 30,
          newsletter: 20,
          nicht_art_74_leistungen: 10,
          kurse_grundlagen: 40,
          treffpunkte_grundlagen: 60,
        )
      end

      context 'time fields' do
        it 'works for simple' do
          expect(report.verwaltung).to eq 250
          total = (50 + 30 + 20 + 40 + 60)
          aufwand = 1050 - 50
          verwaltung = 50
          expect(report.verwaltung).to eq (aufwand * verwaltung / total)
        end

        it 'works for lufeb' do
          total = (50 + 30 + 20 + 40 + 60)
          aufwand = (1050 - 50)
          lufeb = (0 + 40)
          expect(report.lufeb).to eq (aufwand * lufeb / total)
          expect(report.lufeb).to eq 200
        end

        it 'works for treffpunkte' do
          total = (50 + 30 + 20 + 40 + 60)
          aufwand = 1050 - 50
          treffpunkte = (0 + 60)
          expect(report.treffpunkte).to eq (aufwand * treffpunkte / total)
          expect(report.treffpunkte).to eq 300
        end
      end

      context '#total' do
        it 'is calculated correctly' do
          expect(report.total).to eq(1000.0)
        end
      end

    end

    context 'without time record' do

      context 'time fields' do
        it 'works for simple' do
          expect(report.verwaltung).to be_nil
        end

        it 'works for lufeb' do
          expect(report.lufeb).to be_nil
        end
      end

      context '#total' do
        it 'is calculated correctly' do
          expect(report.total).to eq(0.0)
        end
      end

      context '#kontrolle' do
        it 'is calculated correctly' do
          expect(report.kontrolle).to eq(-1000.0)
        end
      end

    end

  end

  context 'without cost accounting record' do
     context 'time fields' do
      it 'works for simple' do
        expect(report.verwaltung).to be_nil
      end

      it 'works for lufeb' do
        expect(report.lufeb).to be_nil
      end
    end

    context '#total' do
      it 'is calculated correctly' do
        expect(report.total).to eq(0.0)
      end
    end
  end

end
