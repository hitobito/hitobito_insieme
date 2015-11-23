# encoding: utf-8

#  Copyright (c) 2012-2014, Jungwacht Blauring Schweiz, Pfadibewegung Schweiz.
#  This file is part of hitobito and licensed under the Affero General Public
#  License version 3 or later. See the COPYING file at the top-level
#  directory or at https://github.com/hitobito/hitobito.

require 'spec_helper'

describe 'CostAccountingCalculator', js: true do

  let(:year) { 2014 }
  let(:group) { groups(:be) }

  context 'honorare' do
    let(:report) { 'honorare' }

    it 'calculates with empty values' do
      sign_in
      visit edit_cost_accounting_report_group_path(year: year, id: group.id, report: report)
      expect(find('#aufwand_ertrag_ko_re')).to have_content('0.00 CHF')
      expect(find('#control_value')).to have_content('0.00 CHF')

      fill_in('cost_accounting_record_aufwand_ertrag_fibu', with: '1000')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('1000.00 CHF')
      expect(find('#control_value')).to have_content('-1000.00 CHF')

      fill_in('cost_accounting_record_abgrenzung_fibu', with: 'jada')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('1000.00 CHF')
      expect(find('#control_value')).to have_content('-1000.00 CHF')

      fill_in('cost_accounting_record_abgrenzung_fibu', with: '200')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('800.00 CHF')
      expect(find('#control_value')).to have_content('-800.00 CHF')


      fill_in('cost_accounting_record_verwaltung', with: '200')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('800.00 CHF')
      expect(find('#control_value')).to have_content('-600.00 CHF')

      fill_in('cost_accounting_record_tageskurse', with: '600')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('800.00 CHF')
      expect(find('#control_value')).to have_content('0.00 CHF')
    end
  end

  context 'indirekte_spenden' do
    let(:report) { 'indirekte_spenden' }

    it 'calculates with empty values' do
      sign_in
      visit edit_cost_accounting_report_group_path(year: year, id: group.id, report: report)
      expect(find('#aufwand_ertrag_ko_re')).to have_content('0.00 CHF')

      fill_in('cost_accounting_record_aufwand_ertrag_fibu', with: '1000')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('1000.00 CHF')
      expect(find('#control_value')).to have_content('-1000.00 CHF')


      fill_in('cost_accounting_record_beratung', with: '200')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('1000.00 CHF')
      expect(find('#control_value')).to have_content('-800.00 CHF')

      fill_in('cost_accounting_record_lufeb', with: '900')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('1000.00 CHF')
      expect(find('#control_value')).to have_content('100.00 CHF')
    end

    it 'calculates with exiting values' do
      create_report('indirekte_spenden', aufwand_ertrag_fibu: 50, treffpunkte: 10)
      create_report('raumaufwand', raeumlichkeiten: 100)
      create_report('honorare', aufwand_ertrag_fibu: 200, verwaltung: 10, beratung: 30)

      sign_in
      visit edit_cost_accounting_report_group_path(year: year, id: group.id, report: report)
      expect(find('#aufwand_ertrag_ko_re')).to have_content('35.00 CHF')
      expect(find('#control_value')).to have_content('-25.00 CHF')

      fill_in('cost_accounting_record_aufwand_ertrag_fibu', with: '100')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('70.00 CHF')
      expect(find('#control_value')).to have_content('-60.00 CHF')


      fill_in('cost_accounting_record_treffpunkte', with: '20')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('70.00 CHF')
      expect(find('#control_value')).to have_content('-50.00 CHF')

      fill_in('cost_accounting_record_mittelbeschaffung', with: '30')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('70.00 CHF')
      expect(find('#control_value')).to have_content('20.00 CHF')
    end

    def create_report(name, values)
      CostAccountingRecord.create!(values.merge(group_id: group.id,
                                                year: year,
                                                report: name))
    end
  end
end
