# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CourseReporting
  class ClientStatistics

    ROLE_ASSOCIATIONS = {
      challenged: :course_record_as_challenged_canton_count,
      affiliated: :course_record_as_affiliated_canton_count
    }

    attr_reader :year

    def initialize(year)
      @year = year
    end

    def roles
      ROLE_ASSOCIATIONS.keys
    end

    def cantons
      Event::ParticipationCantonCount.column_names - %w(id)
    end

    def leistungskategorien
      Event::Reportable::LEISTUNGSKATEGORIEN
    end

    def canton_count(canton, leistungskategorie, role)
      canton_counts[role][leistungskategorie].send(canton).to_i
    end

    def canton_total(leistungskategorie, role)
      canton_counts[role][leistungskategorie].total
    end

    private

    def canton_counts
      @canton_counts ||= begin
        roles.each_with_object({}) do |role, hash|
          hash[role] = Hash.new { |h, k| h[k] = Event::ParticipationCantonCount.new }
          participation_canton_counts(role).each do |counts|
            hash[role][counts.leistungskategorie] = counts
          end
        end
      end
    end

    def participation_canton_counts(role)
      summed_columns = 'events.leistungskategorie, ' + select_sum(cantons)

      Event::ParticipationCantonCount.
        select(summed_columns).
        joins(ROLE_ASSOCIATIONS[role] => :event).
        where(event_course_records: { year: year }).
        group('events.leistungskategorie')
    end

    def select_sum(columns)
      columns.collect { |c| "SUM(#{c}) AS #{c}" }.join(', ')
    end

  end
end
