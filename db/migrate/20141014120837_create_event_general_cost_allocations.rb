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
