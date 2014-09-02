# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class RenamePersonFullName < ActiveRecord::Migration
  def change
    rename_column :people, :name, :full_name

    %w( correspondence_general billing_general correspondence_course billing_course ).
      each do |prefix|
      rename_column :people, "#{prefix}_name", "#{prefix}_full_name"
    end
  end
end
