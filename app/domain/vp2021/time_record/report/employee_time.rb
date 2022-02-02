# frozen_string_literal: true

#  Copyright (c) 2012-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2021
  class TimeRecord::Report::EmployeeTime < TimeRecord::Report::Base

    def paragraph_74
      record.total_paragraph_74_pensum - honorar_pensum('aufwand_ertrag_fibu').to_d
    end

    def not_paragraph_74
      record.total_not_paragraph_74_pensum
    end

    def total
      record.total_pensum - honorar_pensum('total').to_d
    end

    private

    def honorar_pensum(key)
      honorar_costs = table.cost_accounting_value_of('honorare', key).to_d

      price = record.vp_calculations.class::ASSUMED_HOURLY_RATE
      hours = record.vp_calculations.send(:bsv_hours_per_year)

      honorar_costs / (price * hours)
    end

  end
end
