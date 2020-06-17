# frozen_string_literal: true

#  Copyright (c) 2020, insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later. See
#  the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AddCapitalSubstrateLimitToReportingParameters < ActiveRecord::Migration[6.0]
  def change
    add_column :reporting_parameters, :capital_substrate_limit, :decimal, precision: 12, scale: 2

    null_allowed = false
    change_column_null :reporting_parameters, :capital_substrate_limit, null_allowed, 2.0
  end
end
