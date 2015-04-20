# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CostAccounting::Aggregation do

  let(:year) { 2014 }
  let(:aggregation) { CostAccounting::Aggregation.new(year) }

  let(:table_be) { CostAccounting::Table.new(groups(:be), year) }
  let(:table_fr) { CostAccounting::Table.new(groups(:fr), year) }
  let(:table_se) { CostAccounting::Table.new(groups(:seeland), year) }

  before do
    # be
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
                                 tageskurse: 100,
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
                                     newsletter: 20)
    # fr
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
                                 tageskurse: 100,
                                 blockkurse: 500,
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
end
