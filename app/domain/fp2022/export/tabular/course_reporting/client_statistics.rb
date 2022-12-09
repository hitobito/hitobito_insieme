# frozen_string_literal: true

#  Copyright (c) 2020-2021, Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


# see also Fp2015::Export::Tabular::CourseReporting::ClientStatistics
module Fp2022::Export
  module Tabular
    module CourseReporting
      class ClientStatistics
        include Featureperioden::Domain

        class << self
          def csv(stats)
            Export::Csv::Generator.new(new(stats)).call
          end
        end

        delegate :year, to: :stats

        attr_reader :stats

        # Fp2022::CourseReporting::ClientStatistics
        def initialize(stats)
          @stats = stats
        end

        def data_rows(_format = :csv) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
          return enum_for(:data_rows) unless block_given?

          @stats.groups.each do |group|
            yield group_label(group)
            yield group_stats(group.id, 'sk', 'weiterbildung')
            yield group_stats(group.id, 'sk', 'sport')
            yield group_stats(group.id, 'bk', 'weiterbildung')
            yield group_stats(group.id, 'bk', 'sport')
            yield group_stats(group.id, 'tk', 'weiterbildung')
            yield group_stats(group.id, 'tk', 'sport')
            yield group_stats(group.id, 'tp', 'treffpunkt')
            yield empty_row
          end
        end

        def labels
          [
            fp_t('group_or_course_type'),
            fp_t('course_fachkonzept'),
            fp_t('course_count'),
            fp_t('course_hours'),
            fp_t('other_attendees'),
            fp_t('course_total')
          ] + @stats.cantons.map do |canton|
            attr_t("event/participation_canton_count.#{canton}")
          end
        end

        private

        def empty_row
          Array.new(stats.cantons.size + 6, nil)
        end

        def group_label(group)
          [group.name, group.bsv_number, nil, nil, nil, nil] + stats.cantons.map { |_| nil }
        end

        def group_stats(group_id, lk, fachkonzept) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
          gcp = stats.group_participants(group_id, lk, fachkonzept)
          [
            attr_t("event/course.leistungskategorien.#{lk}", count: 3),
            fp_t("fachkonzept.#{fachkonzept}"),
            gcp.course_count.presence,
            course_hours_including_grundlagen_hours(gcp),
            maybe_zero(gcp.other_attendees.to_i),
            maybe_zero(gcp.total.to_i)
          ] + stats.cantons.map do |canton|
            maybe_zero(gcp.send(canton.to_sym).to_i)
          end
        end

        def course_hours_including_grundlagen_hours(gcp)
          grundlagen_field = if gcp.fachkonzept == 'treffpunkt'
            :treffpunkte_grundlagen
          else
            :kurse_grundlagen
          end

          grundlagen_hours = ::TimeRecord.where(
            group_id: gcp.group_id, year: year,
            type: %w(TimeRecord::EmployeeTime TimeRecord::VolunteerWithVerificationTime)
          ).sum(grundlagen_field).to_f

          maybe_zero(gcp.course_hours.to_f + grundlagen_hours)
        end

        def maybe_zero(number)
          number.zero? ? nil : number
        end

        def fp_t(field, options = {})
          I18n.t(field, options.merge(scope: fp_i18n_scope('course_reporting.client_statistics')))
        end

        def attr_t(attr, options = {})
          I18n.t(attr, options.merge(scope: 'activerecord.attributes'))
        end
      end
    end
  end
end
