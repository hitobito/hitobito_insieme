# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CostAccounting::Report::TimeDistributed do

  let(:year) { 2014 }
  let(:group) { groups(:be) }
  let(:table) { CostAccounting::Table.new(group, year) }
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
        TimeRecord.create!(group_id: group.id,
                           year: year,
                           verwaltung: 50,
                           mittelbeschaffung: 30,
                           newsletter: 20)
      end

      context 'time fields' do
        it 'works for simple' do
          report.verwaltung.should eq 500
        end

        it 'works for lufeb' do
          report.lufeb.should eq 200
        end
      end

      context '#total' do
        it 'is calculated correctly' do
          report.total.should eq(1000.0)
        end
      end

    end

    context 'without time record' do

      context 'time fields' do
        it 'works for simple' do
          report.verwaltung.should be_nil
        end

        it 'works for lufeb' do
          report.lufeb.should be_nil
        end
      end

      context '#total' do
        it 'is calculated correctly' do
          report.total.should eq(0.0)
        end
      end

      context '#kontrolle' do
        it 'is calculated correctly' do
          report.kontrolle.should eq(-1000.0)
        end
      end

    end

  end

  context 'without cost accounting record' do
     context 'time fields' do
      it 'works for simple' do
        report.verwaltung.should be_nil
      end

      it 'works for lufeb' do
        report.lufeb.should be_nil
      end
    end

    context '#total' do
      it 'is calculated correctly' do
        report.total.should eq(0.0)
      end
    end
  end

end
