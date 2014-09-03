class AddAllgemeineAuskunftserteilungToTimeRecords < ActiveRecord::Migration
  def change
    add_column(:time_records, :allgemeine_auskunftserteilung, :integer)
  end
end
