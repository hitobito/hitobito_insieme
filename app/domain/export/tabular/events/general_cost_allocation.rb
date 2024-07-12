# frozen_string_literal: true

#  Copyright (c) 2016 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Export
  module Tabular
    module Events
      class GeneralCostAllocation
        class << self
          def csv(entry)
            Export::Csv::Generator.new(new(entry)).call
          end
        end

        attr_reader :entry

        def initialize(entry)
          @entry = entry
        end

        def data_rows(_format = nil)
          return enum_for(:data_rows) unless block_given?

          ::Event::Reportable::LEISTUNGSKATEGORIEN.each do |lk|
            yield values(lk)
          end
        end

        def labels
          [nil,
            ::Event::GeneralCostAllocation.human_attribute_name(:total_direct_costs),
            ::Event::GeneralCostAllocation.human_attribute_name(:general_costs_blockkurse),
            ::Event::GeneralCostAllocation.human_attribute_name(:general_costs_allowance)]
        end

        private

        def values(lk)
          [I18n.t("activerecord.attributes.event/course.leistungskategorien.#{lk}.other"),
            entry.total_costs(lk),
            entry.general_costs(lk),
            entry.general_costs_allowance(lk)]
        end
      end
    end
  end
end
