# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::GeneralCostAllocationJob do

  let(:group) { groups(:be) }
  let(:allocation) { Event::GeneralCostAllocation.create!(group: group, year: 2014) }
  let(:job) { Event::GeneralCostAllocationJob.new(allocation) }

  context 'without courses' do
    it 'performs without doing anything' do
      Event::CourseRecord.delete_all
      expect do
        job.perform
      end.not_to change { Event::CourseRecord.maximum(:gemeinkosten_updated_at) }
    end
  end

  context 'with courses' do

    let(:allocation) do
      Event::GeneralCostAllocation.create!(
        group: group,
        year: 2014,
        general_costs_blockkurse: 3000,
        general_costs_tageskurse: 5000,
        general_costs_semesterkurse: nil,
        general_costs_treffpunkte: 1000)
    end

    before do
      @e1 = create_course_and_course_record(group, 'bk', year: 2014, subventioniert: true, unterkunft: 5000)
      @e2 = create_course_and_course_record(group, 'bk', year: 2014, subventioniert: true, unterkunft: 6000,
                                                         kursdauer: 1, teilnehmende_weitere: 10, inputkriterien: 'c')
      expect(@e2.reload.course_record.zugeteilte_kategorie).to eq('2')

      @e3 = create_course_and_course_record(group, 'sk', year: 2014, subventioniert: true, unterkunft: 3000)
      @e7 = create_course_and_course_record(group, 'tp', year: 2014, subventioniert: true, unterkunft: 5000)
      @e8 = create_course_and_course_record(group, 'tp', year: 2014, subventioniert: true, unterkunft: 2500)

      # not subsidized
      @e4 = create_course_and_course_record(group, 'sk', year: 2014, subventioniert: false, unterkunft: 1000)
      # other year
      @e5 = create_course_and_course_record(group, 'tk', year: 2013, subventioniert: true, unterkunft: 4000)
      # other group
      @e6 = create_course_and_course_record(groups(:seeland), 'bk', year: 2014, subventioniert: true, unterkunft: 2000)
    end

    def create_course_and_course_record(group, leistungskategorie, course_record_attrs)
      fachkonzept = leistungskategorie == 'tp' ? 'treffpunkt' : 'sport_jugend'
      course = Event::Course.create!(name: 'dummy',
                                     groups: [ group ],
                                     leistungskategorie: leistungskategorie,
                                     fachkonzept: fachkonzept,
                                     dates_attributes: [{ start_at: "#{course_record_attrs.delete(:year)}-05-11" }])

      course.create_course_record!(course_record_attrs)
      course
    end

    before { job.perform }

    it 'sets gemeinkosten_updated_at of all considered records' do
      allocation.reload
      expect(@e1.reload.course_record.gemeinkosten_updated_at).to eq(allocation.updated_at)
      expect(@e2.reload.course_record.gemeinkosten_updated_at).to eq(allocation.updated_at)
      expect(@e3.reload.course_record.gemeinkosten_updated_at).to eq(allocation.updated_at)
      expect(@e4.reload.course_record.gemeinkosten_updated_at).to eq(allocation.updated_at)
      expect(@e7.reload.course_record.gemeinkosten_updated_at).to eq(allocation.updated_at)
    end

    it 'does not touch not considered records' do
      expect(@e5.reload.course_record.gemeinkosten_updated_at).to be nil
      expect(@e6.reload.course_record.gemeinkosten_updated_at).to be nil
    end

    it 'sets gemeinkostenanteil correct per leistungskategorie' do
      expect(@e1.reload.course_record.gemeinkostenanteil).to be_within(0.005).of(1363.636)
      expect(@e2.reload.course_record.gemeinkostenanteil).to be_within(0.005).of(1636.363)
      expect(@e3.reload.course_record.gemeinkostenanteil).to eq(0)
      expect(@e4.reload.course_record.gemeinkostenanteil).to eq(0)
      expect(@e7.reload.course_record.gemeinkostenanteil).to be_within(0.005).of(666.67)
      expect(@e8.reload.course_record.gemeinkostenanteil).to be_within(0.005).of(333.33)
    end

    it 're-calculates category' do
      expect(@e2.reload.course_record.zugeteilte_kategorie).to eq('3')
    end

    it 'keeps gemeinkosten sums correct' do
      sums = allocation.considered_course_records.group('events.leistungskategorie').
                                                  sum(:gemeinkostenanteil)
      expect(sums['bk']).to eq allocation.general_costs_blockkurse
      expect(sums['sk']).to eq 0
    end
  end
end
