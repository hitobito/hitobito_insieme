# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CostAccounting
  module Report
    class UmlageRaeumlichkeiten < Base

      delegate :time_record, to: :table

      def self.define_allocated_fields(fields)
        fields.each do |f|
          define_method(f) do
            @allocated_fields ||= {}

            if time_record.total > 0
              @allocated_fields[f] ||= allocated_with_time_record(f)
            else
              @allocated_fields[f] ||= allocated_without_time_record(f)
            end
          end
        end
      end

      define_allocated_fields %w(verwaltung
                                 beratung
                                 treffpunkte
                                 blockkurse
                                 tageskurse
                                 jahreskurse
                                 lufeb
                                 mittelbeschaffung
                                 total)



      def raumaufwand
        table.value_of('raumaufwand', 'raeumlichkeiten').to_d
      end

      def allocated_with_time_record(field)
        (raumaufwand * time_record.send(field).to_d) / (time_record.total - time_record.verwaltung)
      end

      def allocated_without_time_record(_field)
        0.00
      end
    end
  end
end
