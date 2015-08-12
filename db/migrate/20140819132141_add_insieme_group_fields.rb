# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AddInsiemeGroupFields < ActiveRecord::Migration
  def change
    add_column :groups, :full_name, :string
    add_column :groups, :vid, :integer
    add_column :groups, :bsv_number, :integer
    add_column :groups, :canton, :string

    Group.reset_column_information
  end
end
