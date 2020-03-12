class AddFachkonzeptToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :fachkonzept, :string
  end
end
