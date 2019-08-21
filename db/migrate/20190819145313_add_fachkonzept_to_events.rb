class AddFachkonzeptToEvents < ActiveRecord::Migration
  def change
    add_column :events, :fachkonzept, :string
  end
end
