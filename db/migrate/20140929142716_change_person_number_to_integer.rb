class ChangePersonNumberToInteger < ActiveRecord::Migration
  def up
    change_column :people, :number, :integer

    add_index :people, :number, unique: true
  end

  def down
    change_column :people, :number, :string
  end
end
