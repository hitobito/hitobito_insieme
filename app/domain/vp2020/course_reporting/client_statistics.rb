# frozen_string_literal: true

#  Copyright (c) 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# siehe auch Vp2015::CourseReporting::ClientStatistics
module Vp2020::CourseReporting
  class ClientStatistics

    attr_reader :year

    def initialize(year)
      @year = year
    end

    def groups
      load_groups
    end

    def group_canton_count(group_id, canton, leistungskategorie, fachkonzept)
      group_canton_participants[group_id]
        .fetch(leistungskategorie, {})
        .fetch(fachkonzept, GroupCantonParticipant.new)
        .send(canton.to_sym)
        .to_i
    end

    def cantons
      Event::ParticipationCantonCount.column_names - %w(id)
    end

    private

    def load_groups
      @load_groups ||= Event::CourseRecord
                       .where(year: @year, subventioniert: true)
                       .joins(event: [:groups])
                       .includes(event: [:events_groups, :groups])
                       .flat_map { |ecr| ecr.event.groups }
                       .uniq
    end

    GroupCantonParticipant = Struct.new(
      :group_id, :leistungskategorie, :fachkonzept,
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

    def group_canton_participants_relation # rubocop:disable Metrics/MethodLength
      columns = [
        'groups.id AS group_id',
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
