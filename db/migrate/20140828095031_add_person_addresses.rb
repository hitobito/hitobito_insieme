# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AddPersonAddresses < ActiveRecord::Migration
  def add_address_columns(prefix)
    add_column :people, "#{prefix}_name", :string
    add_column :people, "#{prefix}_company_name", :string
    add_column :people, "#{prefix}_company", :boolean, null: false, default: false
    add_column :people, "#{prefix}_address", :string, limit: 1024
    add_column :people, "#{prefix}_zip_code", :integer
    add_column :people, "#{prefix}_town", :string
    add_column :people, "#{prefix}_country", :string
  end

  def change
    add_column :people, :name, :string

    %w( correspondence_general billing_general correspondence_course billing_course ).
      each do |prefix|
        add_address_columns(prefix)
      end
  end
end
