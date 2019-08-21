# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CostAccounting::Aggregation do

  let(:year) { 2016 }
  let(:aggregation) { CostAccounting::Aggregation.new(year) }

  let(:table_be) { CostAccounting::Table.new(groups(:be), year) }
  let(:table_fr) { CostAccounting::Table.new(groups(:fr), year) }
  let(:table_se) { CostAccounting::Table.new(groups(:seeland), year) }

  before do
    # be
    create_course_record(groups(:be), 'tk', nil, 100)
    CostAccountingRecord.create!(group_id: groups(:be).id,
                                 year: year,
                                 report: 'lohnaufwand',
                                 aufwand_ertrag_fibu: 1050,
                                 abgrenzung_fibu: 50)
    CostAccountingRecord.create!(group_id: groups(:be).id,
                                 year: year,
                                 report: 'honorare',
                                 aufwand_ertrag_fibu: 2000,
                                 verwaltung: 1000,
                                 treffpunkte: 200,
                                 lufeb: 200,
                                 mittelbeschaffung: 500)
    CostAccountingRecord.create!(group_id: groups(:be).id,
                                 year: year,
                                 report: 'raumaufwand',
                                 aufwand_ertrag_fibu: 900,
                                 raeumlichkeiten: 400,
                                 verwaltung: 200,
                                 treffpunkte: 300)
    CostAccountingRecord.create!(group_id: groups(:be).id,
                                 year: year,
                                 report: 'leistungsertrag',
                                 aufwand_ertrag_fibu: 1500,
                                 beratung: 200,
                                 treffpunkte: 300,
                                 tageskurse: 500,
                                 lufeb: 100,
                                 mittelbeschaffung: 400)
    CostAccountingRecord.create!(group_id: groups(:be).id,
                                 year: year,
                                 report: 'sonstige_beitraege',
                                 aufwand_ertrag_fibu: 300,
                                 abgrenzung_fibu: 50,
                                 beratung: 50,
                                 tageskurse: 250)
    TimeRecord::EmployeeTime.create!(group_id: groups(:be).id,
                                     year: year,
                                     verwaltung: 50,
                                     treffpunkte: 20,
                                     mittelbeschaffung: 30,
                                     newsletter: 20,
                                     nicht_art_74_leistungen: 10)
    # fr
    create_course_record(groups(:fr), 'tk', nil, 100)
    create_course_record(groups(:fr), 'bk', nil, 500)
    CostAccountingRecord.create!(group_id: groups(:fr).id,
                                 year: year,
                                 report: 'lohnaufwand',
                                 aufwand_ertrag_fibu: 2000)
    CostAccountingRecord.create!(group_id: groups(:fr).id,
                                 year: year,
                                 report: 'honorare',
                                 aufwand_ertrag_fibu: 3000,
                                 verwaltung: 1000,
                                 treffpunkte: 200,
                                 lufeb: 700,
                                 mittelbeschaffung: 500)
    CostAccountingRecord.create!(group_id: groups(:fr).id,
                                 year: year,
                                 report: 'indirekte_spenden',
                                 aufwand_ertrag_fibu: 400,
                                 abgrenzung_fibu: 100,
                                 beratung: 100,
                                 treffpunkte: 300)
    CostAccountingRecord.create!(group_id: groups(:fr).id,
                                 year: year,
                                 report: 'leistungsertrag',
                                 aufwand_ertrag_fibu: 2500,
                                 beratung: 600,
                                 treffpunkte: 800,
                                 blockkurse: 500,
                                 jahreskurse: 200,
                                 mittelbeschaffung: 400)
    TimeRecord::EmployeeTime.create!(group_id: groups(:fr).id,
                                     year: year,
                                     verwaltung: 50,
                                     treffpunkte: 10,
                                     blockkurse: 30,
                                     gremien: 20)
    # seeland
    create_course_record(groups(:seeland), 'sk', 500, nil)
    CostAccountingRecord.create!(group_id: groups(:seeland).id,
                                 year: year,
                                 report: 'lohnaufwand',
                                 aufwand_ertrag_fibu: 550,
                                 abgrenzung_fibu: 50)
    CostAccountingRecord.create!(group_id: groups(:seeland).id,
                                 year: year,
                                 report: 'raumaufwand',
                                 aufwand_ertrag_fibu: 700,
                                 raeumlichkeiten: 200,
                                 verwaltung: 200,
                                 treffpunkte: 200,
                                 lufeb: 100)
    CostAccountingRecord.create!(group_id: groups(:seeland).id,
                                 year: year,
                                 report: 'indirekte_spenden',
                                 aufwand_ertrag_fibu: 600,
                                 abgrenzung_fibu: 50,
                                 beratung: 450,
                                 treffpunkte: 150)
    CostAccountingRecord.create!(group_id: groups(:seeland).id,
                                 year: year,
                                 report: 'leistungsertrag',
                                 aufwand_ertrag_fibu: 1000,
                                 beratung: 500,
                                 blockkurse: 200,
                                 lufeb: 200,
                                 mittelbeschaffung: 100)
  end

  context '#value_of' do
    it 'corresponds to sum of all tables' do
      errors = []
      CostAccounting::Table::REPORTS.each do |report|
        CostAccounting::Report::Base::FIELDS.each do |field|
          value = aggregation.value_of(report.key, field).to_d
          sum = table_be.value_of(report.key, field).to_d +
            table_fr.value_of(report.key, field).to_d +
            table_se.value_of(report.key, field).to_d
          if (value - sum).abs > 0.0001
            errors << "#{report.key}-#{field} is expected to be #{sum}, got #{value}"
          end
        end
      end
      expect(errors).to be_blank, errors.join("\n")
    end
  end

  context '#reports' do
    it 'gives access to all values' do
      lohnaufwand = aggregation.reports['lohnaufwand']
      expect(lohnaufwand.key).to eq('lohnaufwand')
      expect(lohnaufwand.kontengruppe).to eq(CostAccounting::Report::Lohnaufwand.kontengruppe)
      expect(lohnaufwand.aufwand_ertrag_fibu).to eq(3600)
      expect(lohnaufwand.total).to be_within(0.0001).of(3000)
      expect(lohnaufwand.kontrolle).to be_within(0.0001).of(-500)
    end
  end

  context 'course_costs' do
    before do
      # create non subventioniert
      create_course_record(groups(:be), 'tk', 111, 100, 42, false)
      create_course_record(groups(:be), 'bk', 111, 100, 42, false)
      create_course_record(groups(:be), 'sk', 111, 100, 42, false)

      # create subventioniert
      create_course_record(groups(:be), 'bk', nil, nil, 84, true)
      create_course_record(groups(:be), 'sk', 111, 100, 42, true)
    end

    it 'includes subventioniert only' do
      # honorare
      honorare_tageskurse = aggregation.value_of('honorare', 'tageskurse')
      expect(honorare_tageskurse).to eq(200.0)
      honorare_blockkurse = aggregation.value_of('honorare', 'blockkurse')
      expect(honorare_blockkurse).to eq(500.0)
      honorare_jahreskurse = aggregation.value_of('honorare', 'jahreskurse')
      expect(honorare_jahreskurse).to eq(100.0)

      # raumaufwand
      raumaufwand_tageskurse = aggregation.value_of('raumaufwand', 'tageskurse')
      expect(raumaufwand_tageskurse).to be_nil
      raumaufwand_blockkurse = aggregation.value_of('raumaufwand', 'blockkurse')
      expect(raumaufwand_blockkurse).to be_nil
      raumaufwand_jahreskurse = aggregation.value_of('raumaufwand', 'jahreskurse')
      expect(raumaufwand_jahreskurse).to eq(611.0)

      # uebriger_sachaufwand
      uebriges_tageskurse = aggregation.value_of('uebriger_sachaufwand', 'tageskurse')
      expect(uebriges_tageskurse).to be_nil
      uebriges_blockkurse = aggregation.value_of('uebriger_sachaufwand', 'blockkurse')
      expect(uebriges_blockkurse).to eq(84.0)
      uebriges_jahreskurse = aggregation.value_of('uebriger_sachaufwand', 'jahreskurse')
      expect(uebriges_jahreskurse).to eq(42.0)
    end
  end

  def create_course_record(group, lk, unterkunft = nil, honorare = nil, uebriger_sachaufwand = nil, subventioniert = true)
    Event::CourseRecord.create!(
      event: Fabricate(:aggregate_course, groups: [group], leistungskategorie: lk, fachkonzept: 'sport_jugend', year: year),
      unterkunft: unterkunft,
      honorare_inkl_sozialversicherung: honorare,
      uebriges: uebriger_sachaufwand,
      subventioniert: subventioniert
    )
  end

end
