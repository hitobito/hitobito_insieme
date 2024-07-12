# frozen_string_literal: true

#  Copyright (c) 2012-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2022::CostAccounting
  module Report
    class TimeDistributed < Base
      TIME_FIELDS = %w[verwaltung
        beratung
        treffpunkte
        blockkurse
        tageskurse
        jahreskurse
        lufeb
        mittelbeschaffung
        medien_und_publikationen].freeze

      self.used_fields += %w[verwaltung]

      delegate_editable_fields %w[aufwand_ertrag_fibu
        aufteilung_kontengruppen
        abgrenzung_fibu]

      delegate :time_record, to: :table

      TIME_FIELDS.each do |field|
        define_method(field) do # rubocop:disable Metrics/MethodLength
          @time_fields ||= {}
          @time_fields[field] ||=
            if aufwand_ertrag_ko_re.nonzero? && time_record.total_paragraph_74.nonzero?
              time_record_value =
                case field
                when "lufeb" then sum_fields(:lufeb, :kurse_grundlagen)
                when "treffpunkte" then sum_fields(:treffpunkte, :treffpunkte_grundlagen)
                else sum_fields(field.to_sym)
                end

              aufwand_ertrag_ko_re * time_record_value / time_record.total_paragraph_74.abs
            end
        end
      end

      private

      def sum_fields(main_field, *additional_fields)
        ([main_field] + additional_fields).map do |field|
          time_record.send(field).to_d
        end.sum
      end
    end
  end
end
