# frozen_string_literal: true

#  Copyright (c) 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020
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
      (2015..2019).sum do |y|
        time_record_table(y).cost_accounting_value_of('deckungsbeitrag4', 'total').to_d
      end
    end

    def deckungsbeitrag4_vp2020
      (2020..year).sum do |y|
        time_record_table(y).cost_accounting_value_of('deckungsbeitrag4', 'total').to_d
      end
    end

    def deckungsbeitrag4_sum
      deckungsbeitrag4_vp2015 + deckungsbeitrag4_vp2020
    end

    def deckungsbeitrag4
      deckungsbeitrag4_total = table.cost_accounting_value_of('beitraege_iv', 'total').to_d
      return 0 if deckungsbeitrag4_total > DECKUNGSBEITRAG4_THRESHOLD

      deckungsbeitrag4_sum
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

    private

    def time_record_table(year)
      @time_record_tables[year] ||= vp_class('TimeRecord::Table').new(table.group, year)
    end

    def globals
      @globals ||= ReportingParameter.for(table.year)
    end

  end
end
