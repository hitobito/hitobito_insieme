# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AddInsiemePersonFields < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :salutation, :string
    add_column :people, :canton, :string

    unless ActiveRecord::Base.connection.column_exists?(:people, :language)
      add_column :people, :language, :string
    end

    add_column :people, :correspondence_language, :string
    add_column :people, :number, :string
  end
end
