# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CostAccounting::Report::Deckungsbeitrag2 do

  let(:year) { 2016 }
  let(:group) { groups(:be) }
  let(:table) { CostAccounting::Table.new(group, year) }
  let(:report) { table.reports.fetch('deckungsbeitrag2') }

  before do
    create_course_record('bk', 5)
    create_course_record('tk', 4)
    create_course_record('sk', 3)
    create_report('leistungsertrag', beratung: 110, treffpunkte: 111, blockkurse: 112,
                  tageskurse: 113, jahreskurse: 114, lufeb: 115, mittelbeschaffung: 116)
    create_report('raumaufwand', raeumlichkeiten: 100, beratung: 7, treffpunkte: 6,
                  lufeb: 2, mittelbeschaffung: 1)
    create_report('direkte_spenden', beratung: 20, treffpunkte: 21, blockkurse: 22,
                  tageskurse: 23, jahreskurse: 24, lufeb: 25, mittelbeschaffung: 26)
    create_report('indirekte_spenden', beratung: 30, treffpunkte: 31, blockkurse: 32,
                  tageskurse: 33, jahreskurse: 34, lufeb: 35, mittelbeschaffung: 36)

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

  it 'calculates db 1 - total_umlagen + direkte_spenden + indirekte_spenden' do
    expect(report.beratung).to eq(110 - 7 - 30 + 20 + 30)
    expect(report.treffpunkte).to eq(111 - 6 - 20 + 21 + 31)
    expect(report.blockkurse).to eq(112 - 5 - 10 + 22 + 32)
    expect(report.tageskurse).to eq(113 - 4 - 5 + 23 + 33)
    expect(report.jahreskurse).to eq(114 - 3 - 25 + 24 + 34)
    expect(report.lufeb).to eq(115 - 2 - 3 + 25 + 35)
    expect(report.mittelbeschaffung).to eq(116 - 1 - 7 + 26 + 36)
  end

  it 'calculates the correct total' do
    expect(report.total).to eq(1055)
  end

  def create_time_record(values)
    TimeRecord::EmployeeTime.create!(values.merge(group_id: group.id,
                                                  year: year))
  end

  def create_report(name, values)
    CostAccountingRecord.create!(values.merge(group_id: group.id,
                                              year: year,
                                              report: name))
  end

  def create_course_record(lk, unterkunft)
    Event::CourseRecord.create!(
      event: Fabricate(:aggregate_course, groups: [group], leistungskategorie: lk, fachkonzept: 'sport_jugend', year: year),
      unterkunft: unterkunft
    )
  end

end
