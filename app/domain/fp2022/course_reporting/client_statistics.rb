# frozen_string_literal: true

#  Copyright (c) 2020-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# siehe auch Fp2015::CourseReporting::ClientStatistics
module Fp2022::CourseReporting
  class ClientStatistics

    attr_reader :year

    def initialize(year)
      @year = year
    end

    def groups
      load_groups.to_a
    end

    def group_canton_count(group_id, canton, leistungskategorie, fachkonzept)
      group_participants(group_id, leistungskategorie, fachkonzept)
        .send(canton.to_sym)
        .to_i
    end

    def group_participants(group_id, leistungskategorie, fachkonzept)
      group_canton_participants
        .fetch(group_id, {})
        .fetch(leistungskategorie, {})
        .fetch(fachkonzept, GroupCantonParticipant.new)
    end

    def cantons
      Event::ParticipationCantonCount.column_names - %w(id)
    end

    private

    def load_groups
      @load_groups ||= Group.by_bsv_number.all
    end

    GroupCantonParticipant = Struct.new(
      :group_id, :leistungskategorie, :fachkonzept,
      :course_count, :course_hours, :other_attendees,
      :ag, :ai, :ar, :be, :bl, :bs, :fr, :ge, :gl, :gr, :ju, :lu, :ne, :nw,
      :ow, :sg, :sh, :so, :sz, :tg, :ti, :ur, :vd, :vs, :zg, :zh, :another
    ) do
      def total
        [
          :ag, :ai, :ar, :be, :bl, :bs, :fr, :ge, :gl, :gr, :ju, :lu, :ne, :nw,
          :ow, :sg, :sh, :so, :sz, :tg, :ti, :ur, :vd, :vs, :zg, :zh, :another
        ].map { |canton| send(canton).to_i }.sum
      end
    end

    def group_canton_participants
      @group_canton_participants ||=
        raw_group_canton_participants
        .map { |row| GroupCantonParticipant.new(*row) }
        .each_with_object({}) do |gcp, memo|
          memo[gcp.group_id] ||= {}
          memo[gcp.group_id][gcp.leistungskategorie] ||= {}
          memo[gcp.group_id][gcp.leistungskategorie][gcp.fachkonzept] = gcp
        end
    end

    def group_canton_participants_relation # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      columns = [
        '`groups`.id AS group_id',
        'events.leistungskategorie AS event_leistungskategorie'
      ]

      fachkonzepte = {
        freizeit_jugend: 'sport',
        freizeit_erwachsen: 'sport',
        sport_jugend: 'sport',
        sport_erwachsen: 'sport',
        autonomie_foerderung: 'weiterbildung',
        treffpunkt: 'treffpunkt'
      }.map do |fachkonzept, kursinhalt|
        "WHEN '#{fachkonzept}' THEN '#{kursinhalt}'"
      end

      columns << "CASE events.fachkonzept #{fachkonzepte.join(' ')} "\
                 'ELSE events.fachkonzept END AS event_fachkonzept'

      columns << 'SUM(event_course_records.anzahl_kurse) AS course_count'

      columns << <<~SQL.split("\n").map(&:strip).join(' ') # total_tage_teilnehmende
        CASE events.leistungskategorie
        WHEN 'tp' THEN SUM(COALESCE(event_course_records.betreuungsstunden, 0))
        ELSE
          (
            SUM(COALESCE(event_course_records.tage_behinderte, 0)) +
            SUM(COALESCE(event_course_records.tage_angehoerige, 0))
          )
        END AS course_hours
      SQL

      columns << <<~SQL.split("\n").map(&:strip).join(' ')
        CASE events.leistungskategorie
        WHEN 'tp' THEN 0
        ELSE
          CASE events.type
          WHEN 'Event::AggregateCourse' THEN
            SUM(COALESCE(event_course_records.tage_weitere, 0))
          ELSE
            SUM(
              (
                COALESCE(event_course_records.teilnehmende_weitere, 0) *
                event_course_records.kursdauer
              ) - COALESCE(event_course_records.absenzen_weitere, 0)
            )
          END
        END AS other_attendees
      SQL

      cantons.each do |canton|
        columns << "SUM(COALESCE(event_participation_canton_counts.#{canton}, 0)) "\
                   ' + '\
                   "SUM(COALESCE(affiliated_canton_counts_event_course_records.#{canton}, 0)) "\
                   "#{canton}"
      end

      Event::CourseRecord
        .select(columns.join(', '))
        .where(year: @year, subventioniert: true)
        .left_joins(event: [:groups])
        .left_joins(:challenged_canton_count, :affiliated_canton_count)
        .group('group_id, event_leistungskategorie, event_fachkonzept')
    end

    def raw_group_canton_participants
      ActiveRecord::Base.connection.select_rows(group_canton_participants_relation.to_sql)
    end
  end
end
