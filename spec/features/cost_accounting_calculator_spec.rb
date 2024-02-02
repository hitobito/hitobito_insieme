# encoding: utf-8

#  Copyright (c) 2012-2024, Jungwacht Blauring Schweiz, Pfadibewegung Schweiz.
#  This file is part of hitobito and licensed under the Affero General Public
#  License version 3 or later. See the COPYING file at the top-level
#  directory or at https://github.com/hitobito/hitobito.

require 'spec_helper'

describe 'CostAccountingCalculator', js: true do

  let(:year) { 2016 }
  let(:group) { groups(:be) }

  context 'honorare' do
    let(:report) { 'honorare' }

    it 'calculates with empty values and course amounts', js: true do
      create_course_record

      sign_in
      visit edit_cost_accounting_report_group_path(year: year, id: group.id, report: report)

      expect(find('#aufwand_ertrag_ko_re')).to have_content('0.00 CHF')
      expect(find('#control_value')).to have_content('5000.00 CHF')

      fill_in('cost_accounting_record_aufwand_ertrag_fibu', with: '10000')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('10000.00 CHF')
      expect(find('#control_value')).to have_content('-5000.00 CHF')

      fill_in('cost_accounting_record_abgrenzung_fibu', with: 'jada')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('10000.00 CHF')
      expect(find('#control_value')).to have_content('-5000.00 CHF')

      fill_in('cost_accounting_record_abgrenzung_fibu', with: '2000')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('8000.00 CHF')
      expect(find('#control_value')).to have_content('-3000.00 CHF')

      fill_in('cost_accounting_record_verwaltung', with: '200')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('8000.00 CHF')
      expect(find('#control_value')).to have_content('-2800.00 CHF')

      fill_in('cost_accounting_record_treffpunkte', with: '800')
      expect(find('#aufwand_ertrag_ko_re')).to have_content('8000.00 CHF')
      expect(find('#control_value')).to have_content('-2000.00 CHF')

      page.all('form.report button[type=submit]').first.click

      expect(page.find('#flash .alert-success')).to have_content('Honorare wurde erfolgreich aktualisiert.')

      record = CostAccountingRecord.find_by(group_id: group.id, year: year, report: report)
      expect(record.aufwand_ertrag_fibu).to eq(10000.0)
      expect(record.abgrenzung_fibu).to eq(2000.0)
      expect(record.verwaltung).to eq(200.0)
      expect(record.treffpunkte).to eq(800.0)
      expect(record.tageskurse).to be_nil
      expect(record.blockkurse).to be_nil
      expect(record.jahreskurse).to be_nil
    end

    def create_course_record
      Event::CourseRecord.create!(
        event: Fabricate(:course,
                          groups: [group],
                          leistungskategorie: 'bk',
                          fachkonzept: 'sport_jugend',
                          dates_attributes: [{ start_at: Date.new(year, 10, 1) }]),
        year: year,
        honorare_inkl_sozialversicherung: 5000,
        uebriges: 600
      )
    end
  end

  context 'indirekte_spenden' do
    let(:report) { 'indirekte_spenden' }

    it 'calculates with empty values', js: true do
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

    it 'calculates with exiting values', js: true do
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
