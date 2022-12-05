# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2020::CostAccounting
  module Report
    class UmlageVerwaltung < Base

      delegate :time_record, to: :table

      FIELDS = %w(mittelbeschaffung
                  beratung
                  treffpunkte
                  blockkurse
                  tageskurse
                  jahreskurse
                  lufeb
                  medien_und_publikationen).freeze

      FIELDS.each do |field|
        define_method(field) do
          @allocated_fields ||= {}

          if verwaltung.positive?
            @allocated_fields[field] ||= if time_record.total.positive?
                                           allocated_with_time_record(field)
                                         else
                                           allocated_without_time_record(field)
                                         end
          end
        end
      end

      def aufwand_ertrag_ko_re
        nil
      end

      def verwaltung
        @verwaltung ||=
          table.value_of('total_aufwand', 'verwaltung').to_d +
            table.value_of('umlage_personal', 'verwaltung').to_d +
            table.value_of('umlage_raeumlichkeiten', 'verwaltung').to_d
      end

      def total # rubocop:disable Metrics/AbcSize
        @total ||= begin
          mittelbeschaffung.to_d +
          beratung.to_d +
          treffpunkte.to_d +
          blockkurse.to_d +
          tageskurse.to_d +
          jahreskurse.to_d +
          lufeb.to_d +
          medien_und_publikationen.to_d
        end
      end

      def kontrolle
        total - verwaltung
      end

      private

      def allocated_with_time_record(field)
        if relevante_zeit.positive?
          verwaltung * time_record.send(field).to_d / relevante_zeit
        end
      end

      def allocated_without_time_record(field)
        if relevanter_aufwand.positive?
          verwaltung * aufwand(field).to_d / relevanter_aufwand
        end
      end

      def relevante_zeit
        time_record.total_paragraph_74 - time_record.verwaltung.to_i
      end

      def relevanter_aufwand
        @relevanter_aufwand ||=
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
