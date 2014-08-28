# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CostAccounting::Report::Base do

  let(:year) { 2014 }
  let(:group) { groups(:be) }
  let(:table) { CostAccounting::Table.new(group, year) }
  let(:report) { CostAccounting::Report::Lohnaufwand.new(table) }

  before do
    CostAccountingRecord.create!(group_id: group.id,
                                 year: year,
                                 report: 'lohnaufwand',
                                 aufwand_ertrag_fibu: 1000,
                                 abgrenzung_fibu: 50)
  end

  context '#aufwand_ertrag_ko_re' do
    it 'is calculated correctly' do
      report.aufwand_ertrag_ko_re.should eq(950.0)
    end
  end

  context '#total' do
    it 'is calculated correctly' do
      report.total.should eq(950.0)
    end
  end

  context '#kontrolle' do
    it 'is calculated correctly' do
      report.kontrolle.should eq(0.0)
    end
  end

  context 'basic accessors' do
    it 'return nil' do
      report.raeumlichkeiten.should be_nil
    end
  end

  CostAccounting::Table::REPORTS.each do |key, report|
    context key do
      it 'has valid used fields' do
        (report.used_fields - CostAccounting::Report::Base::FIELDS).should eq []
      end

      it 'has valid editable fields' do
        (report.editable_fields - report.used_fields - %w(aufteilung_kontengruppen)).should eq []
      end

      it 'has human name' do
        report.human_name.should match(/^[A-ZÖÄÜ]/)
      end
    end
  end


end
