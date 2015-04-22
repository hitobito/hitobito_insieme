# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Statistics
  class GroupFigures

    attr_reader :year

    def initialize(year)
      @year = year
    end

    def groups
      @groups ||= Group.where(type: [Group::Dachverein,
                                     Group::Regionalverein,
                                     Group::ExterneOrganisation].collect(&:sti_name))
    end

    def leistungskategorien
      Event::Reportable::LEISTUNGSKATEGORIEN
    end

    def kategorien
      %w(1 2 3)
    end

    def participant_effort(group, leistungskategorie, kategorie)
      participant_efforts[group.id][leistungskategorie][kategorie].to_d
    end

    def employee_time(group)
      time_records[group.id][TimeRecord::EmployeeTime.sti_name].to_i
    end

    def volunteer_with_verification_time(group)
      time_records[group.id][TimeRecord::VolunteerWithVerificationTime.sti_name].to_i
    end

    private

    def participant_efforts
      @participant_efforts ||= begin
        hash = Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = {} } }
        load_participant_efforts.each do |record|
          hash[record.group_id][record.leistungskategorie][record.zugeteilte_kategorie] =
            record.total_tage_teilnehmende
        end
        hash
      end
    end

    def load_participant_efforts
      columns = 'events_groups.group_id, events.leistungskategorie, ' \
                'event_course_records.zugeteilte_kategorie, ' \
                'SUM(total_tage_teilnehmende) AS total_tage_teilnehmende'

      Event::CourseRecord.select(columns).
                          joins(:event).
                          joins('INNER JOIN events_groups ON events.id = events_groups.event_id').
                          where(year: year).
                          group('events_groups.group_id, events.leistungskategorie, ' \
                                'event_course_records.zugeteilte_kategorie')
    end

    def time_records
      @time_records ||= begin
        hash = Hash.new { |h, k| h[k] = {} }
        load_time_records.each do |record|
          hash[record.group_id][record.type] = record.total_lufeb
        end
        hash
      end
    end

    def load_time_records
      TimeRecord.where(year: year,
                       type: [TimeRecord::EmployeeTime,
                              TimeRecord::VolunteerWithVerificationTime].collect(&:sti_name))
    end

  end
end
