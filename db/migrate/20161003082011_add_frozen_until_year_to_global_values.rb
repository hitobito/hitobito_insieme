class AddFrozenUntilYearToGlobalValues < ActiveRecord::Migration
  def change
    add_column :global_values, :reporting_frozen_until_year, :integer
  end
end
