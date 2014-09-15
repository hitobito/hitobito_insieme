class AddLeistungskategorieToEvents < ActiveRecord::Migration
  def change
    add_column :events, :leistungskategorie, :string
  end
end
