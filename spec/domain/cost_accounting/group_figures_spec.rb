# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CostAccounting::GroupFigures do

  before do
    TimeRecord::EmployeeTime.create!(group: groups(:be), year: 2015, verwaltung: 10)
    TimeRecord::EmployeeTime.create!(group: groups(:be), year: 2014, verwaltung: 11)
    TimeRecord::EmployeeTime.create!(group: groups(:fr), year: 2015, verwaltung: 12)

    TimeRecord::VolunteerWithVerificationTime.create!(group: groups(:be), year: 2015,
                                                      verwaltung: 20)
    TimeRecord::VolunteerWithVerificationTime.create!(group: groups(:fr), year: 2015,
                                                      verwaltung: 21)

    create_course(2015, :be, 'bk', 'a', 10, 100)
    create_course(2015, :be, 'bk', 'a', 11, 101)
    create_course(2015, :be, 'bk', 'b', 12, 450)
    create_course(2015, :be, 'bk', 'c', 13, 650)
    create_course(2015, :be, 'sk', 'a', 14, 102)
    create_course(2015, :fr, 'bk', 'a', 15, 103)
    create_course(2015, :fr, 'tk', 'a', 16, 104)
    create_course(2015, :fr, 'tk', 'c', 17, 500)

    # other year
    create_course(2014, :fr, 'bk', 'a', 17, 105)
  end

  let(:figures) { described_class.new(2015) }

  context '#participant_efforts' do
    it 'should return the summed totals' do
      expect(figures.participant_effort(groups(:be), 'bk', 'a')).to eq(10 * 100 + 11 * 101)
      expect(figures.participant_effort(groups(:be), 'bk', 'b')).to eq(12 * 450)
      expect(figures.participant_effort(groups(:be), 'bk', 'c')).to eq(13 * 650)
      expect(figures.participant_effort(groups(:be), 'tk', 'a')).to eq(0)
      expect(figures.participant_effort(groups(:be), 'tk', 'b')).to eq(0)
      expect(figures.participant_effort(groups(:be), 'tk', 'c')).to eq(0)
      expect(figures.participant_effort(groups(:be), 'sk', 'a')).to eq(14 * 102)

      expect(figures.participant_effort(groups(:fr), 'bk', 'a')).to eq(15 * 103)
      expect(figures.participant_effort(groups(:fr), 'bk', 'b')).to eq(0)
      expect(figures.participant_effort(groups(:fr), 'bk', 'c')).to eq(0)
      expect(figures.participant_effort(groups(:fr), 'tk', 'a')).to eq(16 * 104)
      expect(figures.participant_effort(groups(:fr), 'tk', 'b')).to eq(0)
      expect(figures.participant_effort(groups(:fr), 'tk', 'c')).to eq(17 * 500)
      expect(figures.participant_effort(groups(:fr), 'sk', 'a')).to eq(0)
    end

    it 'should return 0 for groups without records' do
      expect(figures.participant_effort(groups(:seeland), 'bk', 'a')).to eq(0)
    end
  end

  context '#employee_time' do
    it 'should return the totals' do
      expect(figures.employee_time(groups(:be))).to eq(10)
      expect(figures.employee_time(groups(:fr))).to eq(12)
    end

    it 'should return 0 for groups without records' do
      expect(figures.employee_time(groups(:seeland))).to eq(0)
    end
  end

  context '#volunteer_with_verification_time' do
    it 'should return the totals' do
      expect(figures.volunteer_with_verification_time(groups(:be))).to eq(20)
      expect(figures.volunteer_with_verification_time(groups(:fr))).to eq(21)
    end

    it 'should return 0 for groups without records' do
      expect(figures.volunteer_with_verification_time(groups(:seeland))).to eq(0)
    end
  end

  private

  def create_course(year, groups_keys, leistungskategorie, inputkriterien, kursdauer, teilnehmende)
    event = Fabricate(:course, groups: Array(groups_keys).collect { |k| groups(k) },
                               leistungskategorie: leistungskategorie)
    event.dates.create!(start_at: Time.zone.local(year, 05, 11))
    r = Event::CourseRecord.create!(event_id: event.id, year: year)
    r.update_attributes(inputkriterien: inputkriterien, kursdauer: kursdauer,
                        teilnehmende_weitere: teilnehmende)
  end

end
