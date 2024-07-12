# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2020
  class TimeRecord::Report::CapitalSubstrateLimit < TimeRecord::Report::Base
    self.kind = :capital_substrate

    def paragraph_74
      limit.to_d * table.cost_accounting_value_of("vollkosten", "total")
    end

    private

    def limit
      @limit ||= ReportingParameter.for(table.year).capital_substrate_limit
    end
  end
end
