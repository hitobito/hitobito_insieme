class AddTreffpunkteGeneralCostAllocation < ActiveRecord::Migration
  def change
    add_column :event_general_cost_allocations, :general_costs_treffpunkte, :decimal, precision: 12, scale: 2
  end
end
