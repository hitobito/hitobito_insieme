# frozen_string_literal: true

#  Copyright (c) 2020, insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later. See
#  the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AddEarmarkedFundsToCapitalSubstrates < ActiveRecord::Migration[6.0]
  def change
    add_column :capital_substrates, :earmarked_funds, :decimal, precision: 12, scale: 2
  end
end
