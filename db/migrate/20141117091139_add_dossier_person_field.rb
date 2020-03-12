class AddDossierPersonField < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :dossier, :string
  end
end
