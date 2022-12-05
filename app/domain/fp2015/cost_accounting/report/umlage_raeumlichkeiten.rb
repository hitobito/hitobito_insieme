# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2015::CostAccounting
  module Report
    class UmlageRaeumlichkeiten < Base

      delegate :time_record, to: :table

      FIELDS = %w(verwaltung
                  beratung
                  treffpunkte
                  blockkurse
                  tageskurse
                  jahreskurse
                  lufeb
                  mittelbeschaffung)

      FIELDS.each do |field|
        define_method(field) do
          @allocated_fields ||= {}

          if raeumlichkeiten > 0
            if time_record.total > 0
              @allocated_fields[field] ||= allocated_with_time_record(field)
            else
              @allocated_fields[field] ||= allocated_without_time_record(field)
            end
          end
        end
      end

      def aufwand_ertrag_ko_re
        nil
      end

      # rubocop:disable Metrics/AbcSize
      def total
        @total ||= begin
          verwaltung.to_d +
          beratung.to_d +
          treffpunkte.to_d +
          blockkurse.to_d +
          tageskurse.to_d +
          jahreskurse.to_d +
          lufeb.to_d +
          mittelbeschaffung.to_d
        end
      end
      # rubocop:enable Metrics/AbcSize

      def kontrolle
        total - raeumlichkeiten.to_d
      end

      def raeumlichkeiten
        table.value_of('raumaufwand', 'raeumlichkeiten').to_d
      end

      private

      def allocated_with_time_record(field)
        if relevante_zeit > 0
          raeumlichkeiten * time_record.send(field).to_d / relevante_zeit
        end
      end

      def allocated_without_time_record(field)
        if relevanter_aufwand > 0
          raeumlichkeiten * aufwand(field).to_d / relevanter_aufwand
        end
      end

      def relevante_zeit
        time_record.total_paragraph_74
      end

      def relevanter_aufwand
        FIELDS.inject(0) do |sum, field|
          aufwand(field).to_d + sum
        end
      end

      def aufwand(field)
        table.value_of('total_aufwand', field).to_d
      end
    end
  end
end
