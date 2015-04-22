# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export
  module Csv
    module Statistics
      class GroupFigures

        class << self
          def export(figures)
            Export::Csv::Generator.new(new(figures)).csv
          end
        end

        attr_reader :figures

        def initialize(figures)
          @figures = figures
        end

        def to_csv(generator)
          generator << labels

          figures.groups.each do |group|
            generator << values(group)
          end
        end

        private

        def labels
          labels = [t('name'), t('vid'), t('bsv')]
          iterate_courses do |lk, cat|
            labels << t("participant_days_#{lk}_#{cat}")
          end
          labels << t('lufeb_hours_employees')
          labels << t('lufeb_hours_volunteers')
          labels
        end

        def values(group)
          values = [group.full_name.presence || group.name, group.vid, group.bsv_number]
          iterate_courses do |lk, cat|
            values << figures.participant_effort(group, lk, cat)
          end
          values << figures.employee_time(group)
          values << figures.volunteer_with_verification_time(group)
          values
        end

        def iterate_courses
          figures.leistungskategorien.each do |lk|
            figures.kategorien.each do |cat|
              unless lk == 'sk' && %w(2 3).include?(cat)
                yield lk, cat
              end
            end
          end
        end

        def t(field)
          I18n.t("statistics.group_figures.#{field}")
        end
      end
    end
  end
end
