# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2020
  class TimeRecord::Report::EmployeeEfforts < TimeRecord::Report::Base

    self.kind = :controlling

    def paragraph_74
      table.cost_accounting_value_of('total_personalaufwand', 'aufwand_ertrag_ko_re') -
        table.cost_accounting_value_of('honorare', 'aufwand_ertrag_ko_re')
    end

  end
end
