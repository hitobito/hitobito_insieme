# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AddPeopleDisabledPersonReference < ActiveRecord::Migration
  def change
    add_column :people, :disabled_person_reference, :boolean, default: false
    add_column :people, :disabled_person_first_name, :string
    add_column :people, :disabled_person_last_name, :string
    add_column :people, :disabled_person_address, :string, limit: 1024
    add_column :people, :disabled_person_zip_code, :integer
    add_column :people, :disabled_person_town, :string
    add_column :people, :disabled_person_birthday, :date

    Person.reset_column_information
  end
end
