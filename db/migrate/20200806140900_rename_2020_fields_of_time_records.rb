class Rename2020FieldsOfTimeRecords < ActiveRecord::Migration[6.0]
  def change
    rename_column :time_records, :total_lufeb_media, :total_media
  end
end
