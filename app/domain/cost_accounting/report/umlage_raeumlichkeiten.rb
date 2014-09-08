# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CostAccounting
  module Report
    class UmlageRaeumlichkeiten < Base

      delegate :time_record, to: :table

      def self.define_allocated_fields(field, fields)
        fields.each do |f|
          define_method(f) do
            @allocated_fields ||= {}
            if time_record.total > 0 # Umlagemethode 1
              @allocated_fields[f] ||= (raumaufwand * time_record.send(f).to_d) / (time_record.total - time_record.verwaltung)
            else # TODO: Umlagemethode 2
              0.00
            end
          end
        end
      end

      define_allocated_fields 'raeumlichkeiten', %w(verwaltung
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

    end
  end
end
