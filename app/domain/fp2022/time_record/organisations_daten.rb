# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2022
  class TimeRecord::OrganisationsDaten
    include Featureperioden::Domain

    attr_reader :year

    def initialize(year)
      @year = year
      @data_for = {}
    end

    def vereine
      @vereine ||= Group.by_bsv_number.all
    end

    def data_for(verein)
      raise ArgumentError unless verein.is_a?(Group)

      @data_for[verein.id] ||= Data.new(
        *fetch_organsations_daten(verein, year),
        honorar_zu_mitarbeiter_teiler
      )
    end

    Data = Struct.new(
      :employee_time_total,
      :employee_time_art_74,
      :volunteer_verified_time_total,
      :volunteer_unverified_time_total,
      :volunteer_time_art_74,
      :honorare_total,
      :honorare_art_74,
      :honorar_fte_teiler
    ) do
      def angestellte_insgesamt
        employee_time_total + (honorare_total / honorar_fte_teiler)
      end

      def angestellte_art_74
        employee_time_art_74 + (honorare_art_74 / honorar_fte_teiler)
      end

      def freiwillige_insgesamt
        volunteer_verified_time_total + volunteer_unverified_time_total
      end

      def freiwillige_art_74
        volunteer_time_art_74
      end
    end

    private

    def fetch_organsations_daten(verein, year)
      table = fp_class('TimeRecord::Table').new(verein, year)

      [
        table.value_of('employee_pensum', :total).to_d,
        table.value_of('employee_pensum', :paragraph_74).to_d,
        table.record('volunteer_with_verification_time').total_pensum.to_d,
        table.record('volunteer_without_verification_time').total_pensum.to_d,
        table.record('volunteer_with_verification_time').total_paragraph_74_pensum.to_d,
        table.cost_accounting_value_of('honorare', 'aufwand_ertrag_fibu').to_d,
        table.cost_accounting_value_of('honorare', 'total').to_d
      ]
    end

    def honorar_zu_mitarbeiter_teiler
      @honorar_zu_mitarbeiter_teiler ||= bsv_hours_per_year.to_d * assumed_hourly_rate.to_d
    end

    def bsv_hours_per_year
      ReportingParameter.for(year)&.bsv_hours_per_year ||
        fp_class('TimeRecord::Calculation')::DEFAULT_BSV_HOURS_PER_YEAR
    end

    def assumed_hourly_rate
      fp_class('TimeRecord::Calculation')::ASSUMED_HOURLY_RATE
    end
  end
end
