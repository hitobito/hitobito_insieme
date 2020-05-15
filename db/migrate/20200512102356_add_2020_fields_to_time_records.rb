class Add2020FieldsToTimeRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :time_records, :unterstuetzung_leitorgane, :integer
    add_column :time_records, :freiwilligen_akquisition,  :integer
    add_column :time_records, :auskuenfte,                :integer
    add_column :time_records, :medien_zusammenarbeit,     :integer
    add_column :time_records, :medien_grundlagen,         :integer
    add_column :time_records, :website,                   :integer
    add_column :time_records, :videos,                    :integer
    add_column :time_records, :social_media,              :integer
    add_column :time_records, :beratungsmodule,           :integer
    add_column :time_records, :apps,                      :integer
    add_column :time_records, :total_lufeb_media,         :integer
    add_column :time_records, :kurse_grundlagen,          :integer
  end
end
