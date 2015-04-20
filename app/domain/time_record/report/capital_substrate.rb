# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class TimeRecord::Report::CapitalSubstrate < TimeRecord::Report::Base

  self.kind = :capital_substrate

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

  def half_profit_margin
    table.cost_accounting_value_of('deckungsbeitrag4', 'total').to_d * 0.5.to_d
  end

  def exemption
    - globals.capital_substrate_exemption.to_d
  end

  def capital_substrate_allocated
    organization_capital_allocated.to_d +
    half_profit_margin.to_d +
    record.fund_building.to_d +
    exemption.to_d
  end

  def paragraph_74
    capital_substrate_allocated
  end

  private

  def globals
    @globals ||= ReportingParameter.for(table.year)
  end

end
