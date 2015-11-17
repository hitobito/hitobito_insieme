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
                                     Group::ExterneOrganisation].collect(&:sti_name)).order_by_type
    end

    def leistungskategorien
      Event::Reportable::LEISTUNGSKATEGORIEN
    end

    def kategorien
      %w(1 2 3)
    end

    def course_record(group, leistungskategorie, kategorie)
      course_records[group.id][leistungskategorie][kategorie]
    end

    def employee_time(group)
      time_records[group.id][TimeRecord::EmployeeTime.sti_name]
    end

    def volunteer_with_verification_time(group)
      time_records[group.id][TimeRecord::VolunteerWithVerificationTime.sti_name]
    end

    def volunteer_without_verification_time(group)
      time_records[group.id][TimeRecord::VolunteerWithoutVerificationTime.sti_name]
    end

    private

    def course_records
      @course_records ||= begin
        hash = Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = {} } }
        load_participant_efforts.each do |record|
          hash[record.group_id][record.leistungskategorie][record.zugeteilte_kategorie] = record
        end
        hash
      end
    end

    def load_participant_efforts
      Event::CourseRecord.select(course_record_columns).
                          joins(:event).
                          joins('INNER JOIN events_groups ON events.id = events_groups.event_id').
                          where(year: year).
                          group('events_groups.group_id, events.leistungskategorie, ' \
                                'event_course_records.zugeteilte_kategorie')
    end

    def course_record_columns
      'events_groups.group_id, events.leistungskategorie, ' \
      'event_course_records.zugeteilte_kategorie, ' \
      'SUM(anzahl_kurse) AS anzahl_kurse, ' \
      'SUM(tage_behinderte) AS tage_behinderte, ' \
      'SUM(tage_angehoerige) AS tage_angehoerige, ' \
      'SUM(tage_weitere) AS tage_weitere, ' \
      'SUM(direkter_aufwand) AS direkter_aufwand, ' \
      'SUM(gemeinkostenanteil) AS gemeinkostenanteil'
    end

    def time_records
      @time_records ||= begin
        hash = Hash.new { |h, k| h[k] = {} }
        load_time_records.each do |record|
          hash[record.group_id][record.type] = record
        end
        hash
      end
    end

    def load_time_records
      TimeRecord.where(year: year)
    end

  end
end
