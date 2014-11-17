class AddDossierPersonField < ActiveRecord::Migration
  def change
    add_column :people, :dossier, :string
  end
end
