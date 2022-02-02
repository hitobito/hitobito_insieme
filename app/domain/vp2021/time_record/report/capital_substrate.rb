# frozen_string_literal: true

#  Copyright (c) 2020-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2021
  class TimeRecord::Report::CapitalSubstrate < TimeRecord::Report::Base
    include Vertragsperioden::Domain

    delegate :year, to: :table

    self.kind = :capital_substrate

    DECKUNGSBEITRAG4_THRESHOLD = 300_000.0

    def initialize(*args)
      super
      @time_record_tables = {}
    end

    def allocation_base
      if table.cost_accounting_value_of('total_aufwand', 'aufwand_ertrag_fibu').nonzero?
        table.cost_accounting_value_of('vollkosten', 'total').to_d /
          table.cost_accounting_value_of('total_aufwand', 'aufwand_ertrag_fibu').to_d
      else
        0
      end
    end

    def organization_capital_allocated
      allocation_base.to_d * record.organization_capital.to_d
    end

    def deckungsbeitrag4_vp2015
      record.newest_previous_sum.to_d
    end

    def deckungsbeitrag4_vp2020
      deckungsbeitrag4_period(2020, 2020)
    end

    def deckungsbeitrag4_vp2021
      deckungsbeitrag4_period(2021, current_or(2021, 2023))
    end

    def deckungsbeitrag4_sum
      [
        deckungsbeitrag4_vp2015,
        deckungsbeitrag4_vp2020,
        deckungsbeitrag4_vp2021
      ].sum
    end

    def deckungsbeitrag4
      deckungsbeitrag4_total = table.cost_accounting_value_of('beitraege_iv', 'total').to_d
      return 0 if deckungsbeitrag4_total >= DECKUNGSBEITRAG4_THRESHOLD

      deckungsbeitrag4_sum
    end

    def iv_finanzierungsgrad_vp2015
      iv_finanzierungsgrad_period(2015, 2019).to_d
    end

    def iv_finanzierungsgrad_vp2020
      iv_finanzierungsgrad_period(2020, 2021).to_d
    end

    def iv_finanzierungsgrad_vp2021
      iv_finanzierungsgrad_period(2021, current_or(2021, 2023)).to_d
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
      return upper if current > upper
    end

    private

    def deckungsbeitrag4_period(start, finish)
      (start..finish).sum do |y|
        time_record_table(y).cost_accounting_value_of('deckungsbeitrag4', 'total').to_d
      end
    end

    def iv_finanzierungsgrad_period(start, finish)
      gesamtkosten = (start..finish).sum do |y|
        time_record_table(y).cost_accounting_value_of('total_aufwand', 'aufwand_ertrag_ko_re').to_d
      end

      return 0 if gesamtkosten.zero?

      total_iv_beitrag = (start..finish).sum do |y|
        time_record_table(y).cost_accounting_value_of('beitraege_iv', 'aufwand_ertrag_fibu').to_d
      end

      total_iv_beitrag / gesamtkosten
    end

    def time_record_table(year)
      @time_record_tables[year] ||= vp_class('TimeRecord::Table').new(table.group, year)
    end

    def globals
      @globals ||= ReportingParameter.for(table.year)
    end

  end
end
