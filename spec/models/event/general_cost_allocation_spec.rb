#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: event_general_cost_allocations
#
#  id                          :integer          not null, primary key
#  group_id                    :integer          not null
#  year                        :integer          not null
#  general_costs_blockkurse    :decimal(12, 2)
#  general_costs_tageskurse    :decimal(12, 2)
#  general_costs_semesterkurse :decimal(12, 2)
#  general_costs_treffpunkte   :decimal(12, 2)
#  created_at                  :datetime
#  updated_at                  :datetime
#

require "spec_helper"

describe Event::GeneralCostAllocation do
  context "validations" do
    it "may be attached to regionalverein" do
      a = Event::GeneralCostAllocation.new(group: groups(:be), year: 2014)
      expect(a).to be_valid
    end

    it "may not be attached to active" do
      a = Event::GeneralCostAllocation.new(group: groups(:aktiv), year: 2014)
      expect(a).not_to be_valid
    end
  end

  context "with underlying courses" do
    let(:group) { groups(:be) }

    let(:record) do
      Event::GeneralCostAllocation.create!(
        group: group,
        year: 2014,
        general_costs_blockkurse: nil,
        general_costs_tageskurse: 5000,
        general_costs_semesterkurse: 1000,
        general_costs_treffpunkte: 200
      )
    end

    before do
      # Avoid Fabricate(:course) as it sets event_dates (used by course_record)
      create_course_and_course_record(group, "bk", "sport_jugend", year: 2014, subventioniert: true, unterkunft: 5000)
      create_course_and_course_record(group, "bk", "sport_jugend", year: 2014, subventioniert: true, unterkunft: 6000)
      create_course_and_course_record(group, "sk", "sport_jugend", year: 2014, subventioniert: true, unterkunft: 3000)
      create_course_and_course_record(group, "tp", "treffpunkt", year: 2014, subventioniert: true, unterkunft: 2000)

      # wrong year
      create_course_and_course_record(group, "tk", "sport_jugend", year: 2013, subventioniert: true, unterkunft: 4000)

      # not subsidized
      create_course_and_course_record(group, "sk", "sport_jugend", year: 2014, subventioniert: false, unterkunft: 1000)

      # other group
      create_course_and_course_record(groups(:seeland), "bk", "sport_jugend", year: 2014, subventioniert: true, unterkunft: 2000)
    end

    def create_course_and_course_record(group, leistungskategorie, fachkonzept, course_record_attrs)
      course = Event::Course.create!(name: "dummy",
        groups: [group], leistungskategorie: leistungskategorie, fachkonzept: fachkonzept,
        dates_attributes: [{start_at: "#{course_record_attrs.delete(:year)}-05-11"}])

      course.create_course_record!(course_record_attrs)
    end

    it "calculates total_costs bk" do
      expect(record.total_costs("bk")).to eq 11000
    end

    it "calculates total_costs tk" do
      expect(record.total_costs("tk")).to eq nil
    end

    it "calculates total_costs sk" do
      expect(record.total_costs("sk")).to eq 3000
    end

    it "calculates total_costs tp" do
      expect(record.total_costs("tp")).to eq 2000
    end

    it "calculates cost allowances blockkurse" do
      expect(record.general_costs_allowance("bk")).to eq 0
    end

    it "calculates cost allowances tageskurse" do
      expect(record.general_costs_allowance("tk")).to be nil
    end

    it "calculates cost allowances semesterkurse" do
      expect(record.general_costs_allowance("sk")).to be_within(0.0001).of(0.33333)
    end

    it "calculates cost allowances treffpunkte" do
      expect(record.general_costs_allowance("tp")).to be_within(0.0001).of(0.1)
    end
  end
end
