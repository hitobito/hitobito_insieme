# frozen_string_literal: true

#  Copyright (c) 2021-2023, Insieme Schweiz. This file is part of
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

      @data_for[verein.id] ||= Data.new(*fetch_organsations_daten(verein, year))
    end

    Data = Struct.new(
      :employee_time_total,
      :employee_time_art_74,
      :volunteer_verified_time_total,
      :volunteer_unverified_time_total,
      :volunteer_time_art_74
    ) do
      def angestellte_insgesamt
        employee_time_total
      end

      def angestellte_art_74
        employee_time_art_74
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
        table.record('volunteer_with_verification_time').total_paragraph_74_pensum.to_d
      ]
    end
  end
end
