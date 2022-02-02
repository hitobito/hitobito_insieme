# encoding: utf-8

#  Copyright (c) 2021, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe 'CostAccounting::Report::Base' do

  let(:year) { 2021 }
  let(:group) { groups(:be) }
  let(:table) { vp_class('CostAccounting::Table').new(group, year) }
  let(:report) { vp_class('CostAccounting::Report::Lohnaufwand').new(table) }

  before do
    CostAccountingRecord.create!(group_id: group.id,
                                 year: year,
                                 report: 'lohnaufwand',
                                 aufwand_ertrag_fibu: 1000,
                                 abgrenzung_fibu: 50)
  end

  context '#aufwand_ertrag_ko_re' do
    it 'is calculated correctly' do
      expect(report.aufwand_ertrag_ko_re).to eq(950.0)
    end
  end

  context '#total' do
    it 'is calculated correctly' do
      expect(report.total).to eq(0.0)
    end
  end

  context '#kontrolle' do
    it 'is calculated correctly' do
      expect(report.kontrolle).to eq(-950.0)
    end
  end

  context 'basic accessors' do
    it 'return nil' do
      expect(report.raeumlichkeiten).to be_nil
    end
  end

  Vp2021::CostAccounting::Table::REPORTS.reject do |report|
    report == Vp2021::CostAccounting::Report::Separator
  end.each do |report|
    context report.key do
      it 'is from the right Vertragsperiode' do
        expect(report.name).to match(/^Vp#{year}::/)
      end

      it 'has valid used fields' do
        expect(report.used_fields - vp_class('CostAccounting::Report::Base')::FIELDS).to eq []
      end

      it 'has valid editable fields' do
        expect(report.editable_fields - report.used_fields - %w(aufteilung_kontengruppen)).to eq []
      end

      it 'has human name' do
        expect(report.human_name(year)).to match(/^[A-ZÖÄÜ]/)
      end
    end
  end


end
