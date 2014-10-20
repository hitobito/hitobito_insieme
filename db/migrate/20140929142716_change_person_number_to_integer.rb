# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class ChangePersonNumberToInteger < ActiveRecord::Migration
  def up
    remove_column :people, :number
    add_column :people, :number, :integer

    add_index :people, :number, unique: true
  end

  def down
    change_column :people, :number, :string
  end
end
