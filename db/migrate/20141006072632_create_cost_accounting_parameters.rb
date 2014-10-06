# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class CreateCostAccountingParameters < ActiveRecord::Migration
  def change
    create_table :cost_accounting_parameters do |t|
      t.integer :year, null: false
      t.decimal :vollkosten_le_schwelle1_blockkurs, null: false, precision: 12, scale: 2
      t.decimal :vollkosten_le_schwelle2_blockkurs, null: false, precision: 12, scale: 2
    end

    add_index :cost_accounting_parameters, :year, unique: true
  end
end
