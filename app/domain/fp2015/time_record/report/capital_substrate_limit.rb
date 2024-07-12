# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2015
  class TimeRecord::Report::CapitalSubstrateLimit < TimeRecord::Report::Base
    self.kind = :capital_substrate

    def paragraph_74
      BigDecimal("2") * table.cost_accounting_value_of("vollkosten", "total")
    end
  end
end
