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
        general_costs_semesterkurse: nil)
    end

    before do
      @e1 = Fabricate(:course, groups: [ group ], leistungskategorie: 'bk')
      @e1.create_course_record!(year: 2014, subventioniert: true, unterkunft: 5000)
      @e2 = Fabricate(:course, groups: [ group ], leistungskategorie: 'bk')
      @e2.create_course_record!(year: 2014, subventioniert: true, unterkunft: 6000, kursdauer: 1, teilnehmende_behinderte: 10, inputkriterien: 'c')
      @e2.reload.course_record.zugeteilte_kategorie.should eq('2')
      @e3 = Fabricate(:course, groups: [ group ], leistungskategorie: 'sk')
      @e3.create_course_record!(year: 2014, subventioniert: true, unterkunft: 3000)
      # not subsidized
      @e4 = Fabricate(:course, groups: [ group ], leistungskategorie: 'sk')
      @e4.create_course_record!(year: 2014, subventioniert: false, unterkunft: 1000)
      # other year
      @e5 = Fabricate(:course, groups: [ group ], leistungskategorie: 'tk')
      @e5.create_course_record!(year: 2013, subventioniert: true, unterkunft: 4000)
      # other group
      @e6 = Fabricate(:course, groups: [ groups(:seeland) ], leistungskategorie: 'bk')
      @e6.create_course_record!(year: 2014, subventioniert: true, unterkunft: 2000)
    end

    before { job.perform }

    it 'sets gemeinkosten_updated_at of all considered records' do
      allocation.reload
      @e1.reload.course_record.gemeinkosten_updated_at.should eq(allocation.updated_at)
      @e2.reload.course_record.gemeinkosten_updated_at.should eq(allocation.updated_at)
      @e3.reload.course_record.gemeinkosten_updated_at.should eq(allocation.updated_at)
    end

    it 'does not touch not considered records' do
      @e4.reload.course_record.gemeinkosten_updated_at.should be nil
      @e5.reload.course_record.gemeinkosten_updated_at.should be nil
      @e6.reload.course_record.gemeinkosten_updated_at.should be nil
    end

    it 'sets gemeinkostenanteil correct per leistungskategorie' do
      @e1.reload.course_record.gemeinkostenanteil.should be_within(0.005).of(1363.636)
      @e2.reload.course_record.gemeinkostenanteil.should be_within(0.005).of(1636.363)
      @e3.reload.course_record.gemeinkostenanteil.should eq(0)
    end

    it 're-calculates category' do
      @e2.reload.course_record.zugeteilte_kategorie.should eq('3')
    end

    it 'keeps gemeinkosten sums correct' do
      sums = allocation.considered_course_records.group('events.leistungskategorie').
                                                  sum(:gemeinkostenanteil)
      sums['bk'].should eq allocation.general_costs_blockkurse
      sums['sk'].should eq 0
    end
  end
end
