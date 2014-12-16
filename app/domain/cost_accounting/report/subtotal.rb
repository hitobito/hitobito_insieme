# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CostAccounting
  module Report
    class Subtotal < Base

      class_attribute :summed_reports, :summed_fields

      self.kind = :subtotal

      class << self
        def define_summed_field_methods
          summed_fields.each do |field|
            define_method(field) do
              @summed_fields ||= {}
              @summed_fields[field] ||=
                summed_reports.collect do |report|
                  table.value_of(report, field).to_d
                end.sum
            end
          end
        end
      end

      def kontrolle
        nil
      end

    end
  end
end
