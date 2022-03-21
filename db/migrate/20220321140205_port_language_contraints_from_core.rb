class PortLanguageContraintsFromCore < ActiveRecord::Migration[6.1]
  def up
    change_column_default :people, :language, default_language
    change_column_null :people, :language, false, default_language
  end

  def down
    change_column_null :people, :language, true
    change_column_default :people, :language, nil
  end

  private

  def default_language
    Settings.application.languages.keys.first
  end
end
