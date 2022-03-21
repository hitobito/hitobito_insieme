# frozen_string_literal: true

#  Copyright (c) 2020-2022, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Vp2020::TimeRecord::Report::CapitalSubstrate do
  let(:year) { 2020 }

  let(:group) { groups(:be) }
  let(:table) { vp_class('TimeRecord::Table').new(group, year) }
  subject(:report) { table.reports.fetch('capital_substrate') }

  before do
    create_course_record('tk', 10)
    create_cost_accounting_report('raumaufwand', raeumlichkeiten: 100)
    create_cost_accounting_report('honorare', aufwand_ertrag_fibu: 100, verwaltung: 10,
                                              beratung: 30)
    create_report(TimeRecord::EmployeeTime, verwaltung: 50, beratung: 30, tageskurse: 20)
    CapitalSubstrate.create!(group_id: group.id, year: year, organization_capital: 300_000)
  end

  context '#allocation_base' do
    it 'is 0 if total_aufwand is zero' do
      CostAccountingRecord.find_by(group_id: group.id, year: year, report: 'honorare')
                          .update(aufwand_ertrag_fibu: 0)

      expect(report.allocation_base).to eq(0)
    end

    it 'calculates the correct value if total_aufwand is nonzero' do
      expect(report.allocation_base).to eq(1.5)
    end
  end

  context '#organization_capital_allocated' do
    it 'calculates the correct value' do
      expect(report.organization_capital_allocated).to eq(450_000)
    end
  end

  context '#deckungsbeitrag4' do
    it 'calculates the correct value' do
      expect(report.deckungsbeitrag4).to eq(-150)
    end

    it 'is 0 if beiträge exceed threshold' do
      create_cost_accounting_report('beitraege_iv', beratung: 400_000)
      expect(report.table.cost_accounting_value_of('beitraege_iv', 'total')).to eq(400_000)
      expect(report.class::DECKUNGSBEITRAG4_THRESHOLD).to eq(300_000.0)

      expect(report.deckungsbeitrag4).to eq(0)
    end

    it 'is 0 if beiträge match threshold exactly' do
      create_cost_accounting_report('beitraege_iv', beratung: 300_000)
      expect(report.table.cost_accounting_value_of('beitraege_iv', 'total')).to eq(300_000)
      expect(report.class::DECKUNGSBEITRAG4_THRESHOLD).to eq(300_000.0)

      expect(report.deckungsbeitrag4).to eq(0)
    end

    it 'includes persisted sum of previous years' do
      cs = CapitalSubstrate.find_by(group_id: group.id, year: year)
      cs.update(previous_substrate_sum: 1650.0)

      expect(report.deckungsbeitrag4_vp2015).to eq(1650.0)
      expect(report.deckungsbeitrag4_vp2020).to eq(-150.0)
      expect(report.deckungsbeitrag4_sum).to    eq(1500.0)
    end

    it 'does not include future years' do
      existing_db4 = -150.0

      create_cost_accounting_report('beitraege_iv', beratung: 5_000, year: year)
      create_cost_accounting_report('beitraege_iv', beratung: 7_000, year: year + 1)

      expect(report.deckungsbeitrag4_vp2020).to eq(5_000 + existing_db4)
    end
  end

  context '#exemption' do
    it 'calculates the correct value' do
      expect(report.exemption).to eq(-200_000)
    end

    it 'is 0 if no reporting_parameter is set' do
      ReportingParameter.delete_all # necessary due to the way they are loaded

      expect(ReportingParameter.for(year)).to be_nil
      expect(report.exemption).to eq(0)
    end
  end

  context '#paragraph_74 and #capital_substrate_allocated' do
    it 'calculates the correct value' do
      expect(report.paragraph_74).to eq(249_850)

      expect(report.capital_substrate_allocated).to eq(report.paragraph_74)
    end
  end

  context '#capital_substrate_allocated' do
    it 'does not include fund_building' do
      calculated = 249_850

      expect(report.capital_substrate_allocated).to eq(calculated)

      capital_substrate = CapitalSubstrate.find_by(year: year)
      capital_substrate.update(fund_building: 1000)
      expect(capital_substrate.fund_building.to_i).to_not be_zero

      expect(report.capital_substrate_allocated).to eq(calculated)
    end
  end

  context 'IV Finanzierungsgrad' do
    it 'has assumptions' do
      expect( (2015..2019).to_a.size ).to eq 5
      expect( (2020..2023).to_a.size ).to eq 4
    end

    it 'can be calculated for VP 2015' do
      {
        2015 => [2_000, 200],
      }.each do |year, (aufwand, beitraege)|
        create_cost_accounting_report('abschreibungen', year: year, aufwand_ertrag_fibu: aufwand)
        create_cost_accounting_report('beitraege_iv',  year: year, aufwand_ertrag_fibu: beitraege)
      end

      expect(subject.iv_finanzierungsgrad_vp2015).to eql (0.1 / 5)
    end

    it 'can be calculated for VP 2020' do
      create_cost_accounting_report('abschreibungen', year: 2020, aufwand_ertrag_fibu: 2_000, abgrenzung_fibu: 100)
      create_cost_accounting_report('beitraege_iv',  year: 2020, aufwand_ertrag_fibu: 1_000)

      expect(subject.iv_finanzierungsgrad_vp2020).to eql 0.5
    end

    it 'can be calculated for the current year' do
      create_cost_accounting_report('abschreibungen', aufwand_ertrag_fibu: 10_000, abgrenzung_fibu: 100)
      create_cost_accounting_report('beitraege_iv',  aufwand_ertrag_fibu:  1_000)

      expect(subject.iv_finanzierungsgrad_current).to eql 0.1
    end

    it 'returns zero if no aufwand was recorded' do
      create_cost_accounting_report('abschreibungen', year: 2015, aufwand_ertrag_fibu: 0)

      expect(subject.iv_finanzierungsgrad_vp2015).to eql 0.0
    end

    it 'calculates average over whole VP' do
      {
        2015 => [2_000, 200], # 0.1
        2016 => [1_000, 200], # 0.2
        2017 => [1_000, 200], # 0.2
        2018 => [  500, 200], # 0.4
        2019 => [  200, 200], # 1.0
                              # 1.9 / 5 = 0.38
      }.each do |year, (aufwand, beitraege)|
        create_cost_accounting_report('beitraege_iv',  year: year, aufwand_ertrag_fibu: beitraege)
        create_cost_accounting_report('abschreibungen', year: year, aufwand_ertrag_fibu: aufwand)
      end

      expect(subject.iv_finanzierungsgrad_vp2015).to be_within(0.01).of(0.38)
    end
  end

  context '#not_paragraph_74' do
    it 'is nil' do
      nil
    end
  end

  context '#total' do
    it 'is nil' do
      nil
    end
  end

  context 'current year within bounds' do
    it 'has assumptions' do
      expect(year).to eql 2020
    end

    it 'returns current year if within bounds' do
      expect(subject.current_or(2020, 2023)).to eql 2020
    end

    it 'return lower bound if below' do
      expect(subject.current_or(2022, 2023)).to eql 2022
    end

    it 'return uppper bound if above' do
      expect(subject.current_or(2015, 2019)).to eql 2019
    end
  end

  def create_cost_accounting_report(name, values)
    CostAccountingRecord.create!(values.reverse_merge(group_id: group.id, year: year, report: name))
  end

  def create_report(model_name, values)
    model_name.create!(values.merge(group_id: group.id, year: year))
  end

  def create_course_record(lk, honorare)
    Event::CourseRecord.create!(
      event: Fabricate(:aggregate_course, groups: [group], leistungskategorie: lk, fachkonzept: 'sport_jugend', year: year),
      honorare_inkl_sozialversicherung: honorare
    )
  end
end
