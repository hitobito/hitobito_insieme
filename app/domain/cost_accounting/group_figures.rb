# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CostAccounting
  class GroupFigures

    attr_reader :year

    def initialize(year)
      @year = year
    end

    def groups

    end

    def leistungskategorien
      Event::Reportable::LEISTUNGSKATEGORIEN
    end

    def inputkriterien
      Event::CourseRecord::INPUTKRITERIEN
    end

    def participant_effort(group, leistungskategorie, inputkriterium)
      participant_efforts[group.id][leistungskategorie][inputkriterium].to_d
    end

    def employee_time(group)
      time_records[group.id]['TimeRecord::EmployeeTime'].to_i
    end

    def volunteer_with_verification_time(group)
      time_records[group.id]['TimeRecord::VolunteerWithVerificationTime'].to_i
    end

    private

    def participant_efforts
      @participant_efforts ||= begin
        hash = Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = {} } }
        load_participant_efforts.each do |record|
          hash[record.group_id][record.leistungskategorie][record.inputkriterien] =
            record.total_tage_teilnehmende
        end
        hash
      end
    end

    def load_participant_efforts
      summed_columns = 'events_groups.group_id, events.leistungskategorie, ' \
                       'event_course_records.inputkriterien, ' +
                       select_sum(%w(total_tage_teilnehmende))

      Event::CourseRecord.select(summed_columns).
                          joins(:event).
                          joins('INNER JOIN events_groups ON events.id = events_groups.event_id').
                          where(year: year).
                          group('events_groups.group_id, events.leistungskategorie, ' \
                                'event_course_records.inputkriterien')
    end

    def time_records
      @time_records ||= begin
        hash = Hash.new { |h, k| h[k] = {} }
        load_time_records.each do |record|
          hash[record.group_id][record.type] = record.total
        end
        hash
      end
    end

    def load_time_records
      summed_columns = 'time_records.group_id, time_records.type, time_records.total'

      TimeRecord.select(summed_columns).
                 where(year: year).
                 where('type=? OR type=?', 'TimeRecord::EmployeeTime',
                       'TimeRecord::VolunteerWithVerificationTime')
    end

    def select_sum(columns)
      columns.collect { |c| "SUM(#{c}) AS #{c}" }.join(', ')
    end

  end
end
