# frozen_string_literal: true

#  Copyright (c) 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020::CourseReporting
  class ClientStatistics

    ROLE_ASSOCIATIONS = {
      challenged: :course_record_as_challenged_canton_count,
      affiliated: :course_record_as_affiliated_canton_count
    }.freeze

    ROLE_PARTICIPANTS = {
      challenged: :teilnehmende_behinderte,
      affiliated: :teilnehmende_angehoerige,
      multiple: :teilnehmende_mehrfachbehinderte
    }.freeze

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

    def participant_count(leistungskategorie, role)
      participant_counts[leistungskategorie].send(ROLE_PARTICIPANTS.fetch(role)).to_i
    end

    def canton_count(canton, leistungskategorie, role)
      canton_counts[role][leistungskategorie].send(canton).to_i
    end

    def canton_total(leistungskategorie, role)
      canton_counts[role][leistungskategorie].total
    end

    private

    def participant_counts
      @participant_counts ||= begin
        hash = Hash.new { |h, k| h[k] = Event::CourseRecord.new }
        load_participant_counts.each do |record|
          hash[record.leistungskategorie] = record
        end
        hash
      end
    end

    def load_participant_counts
      summed_columns = 'events.leistungskategorie, ' +
                       select_sum(ROLE_PARTICIPANTS.values)

      Event::CourseRecord.select(summed_columns).
        joins(:event).
        where(year: year, subventioniert: true).
        group('events.leistungskategorie')
    end

    def canton_counts
      @canton_counts ||= begin
        roles.each_with_object({}) do |role, hash|
          hash[role] = Hash.new { |h, k| h[k] = Event::ParticipationCantonCount.new }
          load_canton_counts(role).each do |counts|
            hash[role][counts.leistungskategorie] = counts
          end
        end
      end
    end

    def load_canton_counts(role)
      summed_columns = 'events.leistungskategorie, ' + select_sum(cantons)

      Event::ParticipationCantonCount.
        select(summed_columns).
        joins(ROLE_ASSOCIATIONS[role] => :event).
        where(event_course_records: { year: year, subventioniert: true }).
        group('events.leistungskategorie')
    end

    def select_sum(columns)
      columns.collect { |c| "SUM(#{c}) AS #{c}" }.join(', ')
    end

  end
end
