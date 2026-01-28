# frozen_string_literal: true

#  Copyright (c) 2020-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2024
  class TimeRecord::Report::CapitalSubstrate < TimeRecord::Report::Base
    include Featureperioden::Domain

    delegate :year, to: :table

    self.kind = :capital_substrate

    DECKUNGSBEITRAG4_THRESHOLD = 300_000.0

    def initialize(*args)
      super
      @time_record_tables = {}
    end

    def allocation_base
      if table.cost_accounting_value_of("total_aufwand", "aufwand_ertrag_fibu").nonzero?
        table.cost_accounting_value_of("vollkosten", "total").to_d /
          table.cost_accounting_value_of("total_aufwand", "aufwand_ertrag_fibu").to_d
      else
        0
      end
    end

    def organization_capital_allocated
      allocation_base.to_d * record.organization_capital.to_d
    end

    # display DB4 values per BSV contractperiod
    def deckungsbeitrag4_fp2015
      deckungsbeitrag4_period(2015, 2019)
    end

    def deckungsbeitrag4_fp2020
      deckungsbeitrag4_period(2020, 2023)
    end

    def deckungsbeitrag4_fp2024
      deckungsbeitrag4_period(2024, [2027, table.year].min)
    end

    # total DB4 up to current year
    # newest_previous_sum is defined in App::Models::CapitalSubstrate;
    # the method returns previous_substrate_sum, which is derived from an extern csv
    # and written into the database via lib/tasks/db.rake
    def deckungsbeitrag4_sum
      record.newest_previous_sum.to_d + deckungsbeitrag4_fp2024
    end

    def deckungsbeitrag4
      deckungsbeitrag4_total = table.cost_accounting_value_of("beitraege_iv", "total").to_d
      return 0 if deckungsbeitrag4_total >= DECKUNGSBEITRAG4_THRESHOLD

      deckungsbeitrag4_sum
    end

    def iv_finanzierungsgrad_since_2015
      iv_finanzierungsgrad_period(2015, table.year).to_d
    end

    def iv_finanzierungsgrad_fp2015
      iv_finanzierungsgrad_period(2015, 2019).to_d
    end

    def iv_finanzierungsgrad_fp2020
      iv_finanzierungsgrad_period(2020, current_or(2020, 2023)).to_d
    end

    def iv_finanzierungsgrad_current
      iv_finanzierungsgrad_period(table.year, table.year).to_d
    end

    def exemption
      globals ? - globals.capital_substrate_exemption.to_d : 0
    end

    def capital_substrate_allocated
      organization_capital_allocated.to_d +
        record.earmarked_funds.to_d +
        deckungsbeitrag4.to_d +
        exemption.to_d
    end

    def paragraph_74
      capital_substrate_allocated
    end

    def current_or(lower, upper)
      current = table.year

      return current if (lower..upper).cover?(current)

      return lower if current < lower
      upper if current > upper
    end

    private

    def deckungsbeitrag4_period(start, finish)
      (start..finish).sum do |y|
        time_record_table(y).cost_accounting_value_of("deckungsbeitrag4", "total").to_d
      end
    end

    def iv_finanzierungsgrad_period(start, finish)
      summe_finanzierungsgrade = (start..finish).sum do |y|
        total_iv_beitrag = time_record_table(y).cost_accounting_value_of("beitraege_iv", "aufwand_ertrag_fibu").to_d # rubocop:disable Layout/LineLength
        gesamtkosten = time_record_table(y).cost_accounting_value_of("total_aufwand", "aufwand_ertrag_ko_re").to_d # rubocop:disable Layout/LineLength

        next BigDecimal(0) if gesamtkosten.zero?

        total_iv_beitrag / gesamtkosten
      end

      anzahl_jahre = (start..finish).to_a.size.to_d

      summe_finanzierungsgrade / anzahl_jahre
    end

    def time_record_table(year)
      @time_record_tables[year] ||= fp_class("TimeRecord::Table").new(table.group, year)
    end

    def globals
      @globals ||= ReportingParameter.for(table.year)
    end
  end
end
