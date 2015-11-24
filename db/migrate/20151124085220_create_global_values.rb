class CreateGlobalValues < ActiveRecord::Migration
  def change
    create_table :global_values do |t|
      t.integer :default_reporting_year, null: false
    end

    GlobalValue.create!(default_reporting_year: Time.zone.now.year)
  end
end
