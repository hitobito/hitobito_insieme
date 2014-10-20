# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class CreateEventGeneralCostAllocations < ActiveRecord::Migration
  def change
    create_table :event_general_cost_allocations do |t|
      t.belongs_to :group, null: false
      t.integer :year, null: false
      t.decimal :general_costs_blockkurse, precision: 12, scale: 2
      t.decimal :general_costs_tageskurse, precision: 12, scale: 2
      t.decimal :general_costs_semesterkurse, precision: 12, scale: 2
      t.timestamps
    end

    add_index :event_general_cost_allocations, [:group_id, :year], unique: true
  end
end
