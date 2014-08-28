# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CostAccounting::Report::Subtotal do

  let(:year) { 2014 }
  let(:group) { groups(:be) }
  let(:table) { CostAccounting::Table.new(group, year) }
  let(:report) { table.reports.fetch('total_personalaufwand') }

  before do
    CostAccountingRecord.create!(group_id: group.id,
                                 year: year,
                                 report: 'lohnaufwand',
                                 aufwand_ertrag_fibu: 1050,
                                 abgrenzung_fibu: 50)

    CostAccountingRecord.create!(group_id: group.id,
                                 year: year,
                                 report: 'sozialversicherungsaufwand',
                                 aufwand_ertrag_fibu: 2000)

    TimeRecord.create!(group_id: group.id,
                       year: year,
                       verwaltung: 50,
                       mittelbeschaffung: 30,
                       newsletter: 20)

  end


  context 'summed fields' do
    it 'works for fibu' do
      report.aufwand_ertrag_fibu.to_f.should eq 3050
    end

    it 'works for simple' do
      report.verwaltung.to_f.should eq 1500
    end

    it 'works for lufeb' do
      report.lufeb.to_f.should eq 600
    end
  end

  context '#aufwand_ertrag_ko_re' do
    it 'is calculated correctly' do
      report.aufwand_ertrag_ko_re.to_f.should eq(3000.0)
    end
  end

  context '#total' do
    it 'is calculated correctly' do
      report.total.to_f.should eq(3000.0)
    end
  end

end
