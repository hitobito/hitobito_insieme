# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Statistics::GroupFigures do

  before do
    TimeRecord::EmployeeTime.create!(group: groups(:be), year: 2015, interviews: 10)
    TimeRecord::EmployeeTime.create!(group: groups(:be), year: 2014, newsletter: 11)
    TimeRecord::EmployeeTime.create!(group: groups(:fr), year: 2015, projekte: 12)

    TimeRecord::VolunteerWithVerificationTime.create!(
      group: groups(:be), year: 2015, vermittlung_kontakte: 20)
    TimeRecord::VolunteerWithVerificationTime.create!(
      group: groups(:fr), year: 2015, referate: 21)

    create_course(2015, :be, 'bk', '1', 10, 100)
    create_course(2015, :be, 'bk', '1', 11, 101)
    create_course(2015, :be, 'bk', '2', 12, 450)
    create_course(2015, :be, 'bk', '3', 13, 650)
    create_course(2015, :be, 'sk', '1', 14, 102)
    create_course(2015, :fr, 'bk', '1', 15, 103)
    create_course(2015, :fr, 'tk', '1', 16, 104)
    create_course(2015, :fr, 'tk', '3', 17, 500)

    # other year
    create_course(2014, :fr, 'bk', '1', 17, 105)
  end

  let(:figures) { described_class.new(2015) }

  context '#participant_efforts' do
    it 'should return the summed totals' do
      expect(figures.participant_effort(groups(:be), 'bk', '1')).to eq(10 * 100 + 11 * 101)
      expect(figures.participant_effort(groups(:be), 'bk', '2')).to eq(12 * 450)
      expect(figures.participant_effort(groups(:be), 'bk', '3')).to eq(13 * 650)
      expect(figures.participant_effort(groups(:be), 'tk', '1')).to eq(0)
      expect(figures.participant_effort(groups(:be), 'tk', '2')).to eq(0)
      expect(figures.participant_effort(groups(:be), 'tk', '3')).to eq(0)
      expect(figures.participant_effort(groups(:be), 'sk', '1')).to eq(14 * 102)

      expect(figures.participant_effort(groups(:fr), 'bk', '1')).to eq(15 * 103)
      expect(figures.participant_effort(groups(:fr), 'bk', '2')).to eq(0)
      expect(figures.participant_effort(groups(:fr), 'bk', '3')).to eq(0)
      expect(figures.participant_effort(groups(:fr), 'tk', '1')).to eq(16 * 104)
      expect(figures.participant_effort(groups(:fr), 'tk', '2')).to eq(0)
      expect(figures.participant_effort(groups(:fr), 'tk', '3')).to eq(17 * 500)
      expect(figures.participant_effort(groups(:fr), 'sk', '1')).to eq(0)
    end

    it 'should return 0 for groups without records' do
      expect(figures.participant_effort(groups(:seeland), 'bk', '1')).to eq(0)
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

  def create_course(year, group_key, leistungskategorie, kategorie, kursdauer, teilnehmende)
    event = Fabricate(:course, groups: [groups(group_key)],
                               leistungskategorie: leistungskategorie)
    event.dates.create!(start_at: Time.zone.local(year, 05, 11))
    r = Event::CourseRecord.create!(event_id: event.id,
                                    year: year,
                                    kursdauer: kursdauer,
                                    teilnehmende_weitere: teilnehmende)
    r.update_column(:zugeteilte_kategorie, kategorie)
  end

end
