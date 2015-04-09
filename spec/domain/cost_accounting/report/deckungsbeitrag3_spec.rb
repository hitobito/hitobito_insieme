# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CostAccounting::Report::Deckungsbeitrag3 do

  let(:year) { 2014 }
  let(:group) { groups(:be) }
  let(:table) { CostAccounting::Table.new(group, year) }
  let(:report) { table.reports.fetch('deckungsbeitrag3') }

  before do
    create_report('leistungsertrag', beratung: 110, treffpunkte: 111, blockkurse: 112,
                  tageskurse: 113, jahreskurse: 114, lufeb: 115, mittelbeschaffung: 116)
    create_report('raumaufwand', raeumlichkeiten: 100, beratung: 7, treffpunkte: 6,
                  blockkurse: 5, tageskurse: 4, jahreskurse: 3, lufeb: 2, mittelbeschaffung: 1)
    create_report('direkte_spenden', beratung: 20, treffpunkte: 21, blockkurse: 22,
                  tageskurse: 23, jahreskurse: 24, lufeb: 25, mittelbeschaffung: 26)
    create_report('sonstige_beitraege', beratung: 1, treffpunkte: 2, blockkurse: 3,
                  tageskurse: 4, jahreskurse: 5, lufeb: 6, mittelbeschaffung: 7)

    create_time_record(beratung: 30, treffpunkte: 20, blockkurse: 10, tageskurse: 5,
                       jahreskurse: 25, kontakte_medien: 3, mittelbeschaffung: 7)
  end

  it 'sets unused fields to nil' do
    expect(report.aufteilung_kontengruppen).to be_nil
    expect(report.aufwand_ertrag_fibu).to be_nil
    expect(report.abgrenzung_fibu).to be_nil
    expect(report.abgrenzung_dachorganisation).to be_nil
    expect(report.aufwand_ertrag_ko_re).to be_nil
    expect(report.personal).to be_nil
    expect(report.raeumlichkeiten).to be_nil
    expect(report.verwaltung).to be_nil
    expect(report.kontrolle).to be_nil
  end

  it 'calculates db 2 + sonstige_beitraege' do
    expect(report.beratung).to eq(110 - 7 - 30 + 20 + 1)
    expect(report.treffpunkte).to eq(111 - 6 - 20 + 21 + 2)
    expect(report.blockkurse).to eq(112 - 5 - 10 + 22 + 3)
    expect(report.tageskurse).to eq(113 - 4 - 5 + 23 + 4)
    expect(report.jahreskurse).to eq(114 - 3 - 25 + 24 + 5)
    expect(report.lufeb).to eq(115 - 2 - 3 + 25 + 6)
    expect(report.mittelbeschaffung).to eq(116 - 1 - 7 + 26 + 7)
  end

  it 'calculates the correct total' do
    expect(report.total).to eq(852)
  end

  def create_time_record(values)
    TimeRecord.create!(values.merge(group_id: group.id,
                                    year: year))
  end

  def create_report(name, values)
    CostAccountingRecord.create!(values.merge(group_id: group.id,
                                              year: year,
                                              report: name))
  end
end
