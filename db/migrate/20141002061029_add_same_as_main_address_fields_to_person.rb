# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AddSameAsMainAddressFieldsToPerson < ActiveRecord::Migration
  def change
    Person::ADDRESS_TYPES.each do |prefix|
      add_column :people, "#{prefix}_same_as_main", :boolean, default: true
    end
  end
end
