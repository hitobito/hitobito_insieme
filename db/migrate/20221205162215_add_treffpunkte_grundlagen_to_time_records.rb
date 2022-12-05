class AddTreffpunkteGrundlagenToTimeRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :time_records, :treffpunkte_grundlagen, :integer
  end
end
