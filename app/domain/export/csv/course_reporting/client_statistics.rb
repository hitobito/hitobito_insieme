# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export
  module Csv
    module CourseReporting
      class ClientStatistics

        class << self
          def export(stats)
            Export::Csv::Generator.new(new(stats)).csv
          end
        end

        attr_reader :stats

        def initialize(stats)
          @stats = stats
        end

        def to_csv(generator)
          generator << labels
          generator << participant_values
          generator << multiple_challenged_values
          stats.cantons.each do |canton|
            generator << canton_values(canton)
          end
          generator << canton_totals
        end

        private

        def labels
          label = I18n.t('course_reporting.client_statistics.disability_or_canton')
          values(label) do |lk, role|
            I18n.t("activerecord.attributes.event/course.leistungskategorien.#{lk}", count: 3) +
            ' ' +
            I18n.t("course_reporting.client_statistics.#{role}")
          end
        end

        def participant_values
          label = I18n.t('course_reporting.client_statistics.participants')
          values(label) do |lk, role|
            stats.participant_count(lk, role)
          end
        end

        def multiple_challenged_values
          label = I18n.t('course_reporting.client_statistics.multiple_challenged')
          values(label) do |lk, role|
            if role == :challenged
              stats.participant_count(lk, :multiple)
            end
          end
        end

        def canton_values(canton)
          label = Cantons.full_name(canton)
          values(label) do |lk, role|
            stats.canton_count(canton, lk, role).to_i
          end
        end

        def canton_totals
          label = I18n.t('course_reporting.client_statistics.total')
          values(label) do |lk, role|
            stats.canton_total(lk, role)
          end
        end

        def values(label)
          [label].tap do |result|
            each_column do |lk, role|
              result << yield(lk, role)
            end
          end
        end

        def each_column
          stats.leistungskategorien.each do |lk|
            stats.roles.each do |role|
              yield lk, role
            end
          end
        end

        def human(field)
          I18n.t("activerecord.attributes.course_reporting.#{field}")
        end
      end
    end
  end
end
