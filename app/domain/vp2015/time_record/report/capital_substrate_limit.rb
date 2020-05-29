#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2015
  class TimeRecord::Report::CapitalSubstrateLimit < TimeRecord::Report::Base

    self.kind = :capital_substrate

    def paragraph_74
      2.to_d * table.cost_accounting_value_of('vollkosten', 'total')
    end

  end
end
