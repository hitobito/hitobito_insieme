# frozen_string_literal: true

#  Copyright (c) 2020, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2022
  class TimeRecord::Report::CapitalSubstrateFactor < TimeRecord::Report::Base

    self.kind = :capital_substrate

    def paragraph_74
      return 0 if vollkosten_total.zero?

      capital_substrate / vollkosten_total
    end

    private

    def capital_substrate
      table.value_of('capital_substrate', 'paragraph_74')
    end

    def vollkosten_total
      table.cost_accounting_value_of('vollkosten', 'total')
    end

  end
end
