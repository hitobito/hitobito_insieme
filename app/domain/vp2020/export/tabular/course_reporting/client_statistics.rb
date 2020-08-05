# frozen_string_literal: true

#  Copyright (c) 2020 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


# see also Vp2015::Export::Tabular::CourseReporting::ClientStatistics
module Vp2020::Export
  module Tabular
    module CourseReporting
      class ClientStatistics
        include Vertragsperioden::Domain

        class << self
          def csv(stats)
            Export::Csv::Generator.new(new(stats)).call
          end
        end

        delegate :year, to: :stats

        attr_reader :stats

        def initialize(stats)
          @stats = stats
        end

        def data_rows(_format = :csv)
          return enum_for(:data_rows) unless block_given?

          @stats.groups.each do |group|
            yield group_label(group)
            yield group_stats(group.id, 'sk')
            yield group_stats(group.id, 'bk')
            yield group_stats(group.id, 'tk')
            yield group_stats(group.id, 'tp')
            yield empty_row
          end
        end

        def labels
          [vp_t('group_or_course_type')] + @stats.cantons.map do |canton|
            attr_t("event/participation_canton_count.#{canton}")
          end
        end

        private

        def empty_row
          Array.new(stats.cantons.size + 1, nil)
        end

        def group_label(group)
          [group.name] + stats.cantons.map { |_| nil }
        end

        def group_stats(group_id, lk)
          [
            attr_t("event/course.leistungskategorien.#{lk}", count: 3)
          ] + stats.cantons.map do |canton|
            gcc = stats.group_canton_count(group_id, canton, lk)
            gcc.zero? ? nil : gcc
          end
        end

        def vp_t(field, options = {})
          I18n.t(field, options.merge(scope: vp_i18n_scope('course_reporting.client_statistics')))
        end

        def attr_t(attr, options = {})
          I18n.t(attr, options.merge(scope: 'activerecord.attributes'))
        end
      end
    end
  end
end
