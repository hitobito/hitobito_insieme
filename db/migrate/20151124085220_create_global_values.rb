class CreateGlobalValues < ActiveRecord::Migration[4.2]
  def change
    create_table :global_values do |t|
      t.integer :default_reporting_year, null: false
    end

    execute "insert into global_values (default_reporting_year) values (#{Time.zone.now.year})"
  end
end
