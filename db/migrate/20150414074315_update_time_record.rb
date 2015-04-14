# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class UpdateTimeRecord < ActiveRecord::Migration
  def change
    add_column :time_records, :type, :string, null: false, default: 'TimeRecord::EmployeeTime'
    add_column :time_records, :nicht_art_74_leistungen, :integer

    add_column :reporting_parameters, :bsv_hours_per_year, :integer, null: false, default: 1900

    remove_index :time_records, [:group_id, :year]
    add_index :time_records, [:type, :group_id, :year], unique: true

    # Remove defaults again
    reversible do |dir|
      dir.up do
        change_column_default(:time_records, :type, nil)
        change_column_default(:reporting_parameters, :bsv_hours_per_year, nil)
      end
    end
  end
end
