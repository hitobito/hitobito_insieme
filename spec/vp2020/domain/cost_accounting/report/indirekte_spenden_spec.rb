# encoding: utf-8

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe 'CostAccounting::Report::IndirekteSpenden' do

  let(:year) { 2020 }
  let(:group) { groups(:be) }
  let(:table) { vp_class('CostAccounting::Table').new(group, year) }
  let(:report) { table.reports.fetch('indirekte_spenden') }


  before do
    create_report('indirekte_spenden', aufwand_ertrag_fibu: 50)
    create_report('raumaufwand', raeumlichkeiten: 100)
    create_report('honorare', aufwand_ertrag_fibu: 200, verwaltung: 10, beratung: 30)
  end

  context 'abgrenzung_fibu' do
    it 'defaults to nil if total_aufwand.aufwand_ertrag_fibu is zero' do
      CostAccountingRecord.find_by(report: 'honorare').
        update_column(:aufwand_ertrag_fibu, nil)

      expect(report.abgrenzung_fibu).to be_nil
    end

    it 'calculates abgrenzung_fibu if total_aufwand.aufwand_ertrag_fibu is nonzero' do
      expect(report.abgrenzung_fibu).to eq(15)
    end
  end

  def create_report(name, values)
    CostAccountingRecord.create!(values.merge(group_id: group.id,
                                              year: year,
                                              report: name))
  end
end
