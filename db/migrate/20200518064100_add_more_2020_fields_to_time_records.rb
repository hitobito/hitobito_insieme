class AddMore2020FieldsToTimeRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :time_records, :lufeb_grundlagen, :integer
  end
end
