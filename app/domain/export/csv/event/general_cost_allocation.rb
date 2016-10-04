# encoding: utf-8

#  Copyright (c) 2016 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export
  module Csv
    module Event
      class GeneralCostAllocation

        class << self
          def export(entry)
            Export::Csv::Generator.new(new(entry)).csv
          end
        end

        attr_reader :entry

        def initialize(entry)
          @entry = entry
        end

        def to_csv(generator)
          generator << labels
          ::Event::Reportable::LEISTUNGSKATEGORIEN.each do |lk|
            generator << values(lk)
          end
        end

        private

        def labels
          [nil,
           ::Event::GeneralCostAllocation.human_attribute_name(:total_direct_costs),
           ::Event::GeneralCostAllocation.human_attribute_name(:general_costs_blockkurse),
           ::Event::GeneralCostAllocation.human_attribute_name(:general_costs_allowance)]
        end

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
