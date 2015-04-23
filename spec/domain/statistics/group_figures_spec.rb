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

    @course_records = Event::CourseRecord.joins(:event).where(year: 2015)
  end

  let(:figures) { described_class.new(2015) }

  context '#groups' do
    it 'returns group sorted by type' do
      expect(figures.groups).to eq [groups(:dachverein),
                                    groups(:fr),
                                    groups(:be),
                                    groups(:seeland)]
    end
  end



  context '#participant_efforts' do
    it 'should return the summed totals' do
      %w(be fr).product(%w(bk sk), %w(1 2 3)).each do |group_key, lk, zk|
        group = groups(group_key)
        records = course_records(group, lk, zk)
        summed_total_tage_teilnehmende = records.sum(&:total_tage_teilnehmende)

        expect(figures.participant_effort(groups(group_key), lk, zk)).to eq(summed_total_tage_teilnehmende),
          "expected figures.participant_effort(#{group_key}, #{lk}, #{zk}) to eq #{summed_total_tage_teilnehmende}"
      end

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

      expect(figures.employee_time(groups(:be))).to eq(employee_total_lufeb(:be))
      expect(figures.employee_time(groups(:fr))).to eq(employee_total_lufeb(:fr))
    end

    it 'should return 0 for groups without records' do
      expect(figures.employee_time(groups(:seeland))).to eq(0)
    end
  end

  context '#volunteer_with_verification_time' do
    it 'should return the totals' do
      expect(figures.volunteer_with_verification_time(groups(:be))).to eq(20)
      expect(figures.volunteer_with_verification_time(groups(:fr))).to eq(21)

      expect(figures.volunteer_with_verification_time(groups(:be))).to eq(volunteer_total_lufeb(:be))
      expect(figures.volunteer_with_verification_time(groups(:fr))).to eq(volunteer_total_lufeb(:fr))
    end

    it 'should return 0 for groups without records' do
      expect(figures.volunteer_with_verification_time(groups(:seeland))).to eq(0)
    end
  end

  private

  def course_records(group, leistungskategorie, zugeteilte_kategorie)
    @course_records.select { |r| r.event.groups.first == group &&
                             r.event.leistungskategorie == leistungskategorie  &&
                             r.zugeteilte_kategorie == zugeteilte_kategorie }
  end

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

  def employee_total_lufeb(group_key, year = 2015)
    TimeRecord::EmployeeTime.find_by_group_id_and_year(groups(group_key).id, year).total_lufeb
  end

  def volunteer_total_lufeb(group_key, year = 2015)
    TimeRecord::VolunteerWithVerificationTime.find_by_group_id_and_year(groups(group_key).id, year).total_lufeb
  end

end
