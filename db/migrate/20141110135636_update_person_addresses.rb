# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class UpdatePersonAddresses < ActiveRecord::Migration[4.2]

  def update_address_columns(prefix)
    remove_column :people, "#{prefix}_full_name", :string
    add_column :people, "#{prefix}_salutation", :string
    add_column :people, "#{prefix}_first_name", :string
    add_column :people, "#{prefix}_last_name", :string
  end

  def change
    remove_column :people, :insieme_full_name, :string

    %w( correspondence_general billing_general correspondence_course billing_course ).
      each do |prefix|
        update_address_columns(prefix)
      end
  end
end
