# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class UpdateTimeRecord < ActiveRecord::Migration[4.2]
  def change
    add_column :time_records, :type, :string
    TimeRecord.update_all(type: 'TimeRecord::EmployeeTime')
    change_column :time_records, :type, :string, null: false

    add_column :time_records, :total_lufeb_general, :integer
    add_column :time_records, :total_lufeb_private, :integer
    add_column :time_records, :total_lufeb_specific, :integer
    add_column :time_records, :total_lufeb_promoting, :integer
    add_column :time_records, :nicht_art_74_leistungen, :integer

    add_column :reporting_parameters, :bsv_hours_per_year, :integer
    ReportingParameter.update_all(bsv_hours_per_year: 1900)
    change_column :reporting_parameters, :bsv_hours_per_year, :integer, null: false

    remove_index :time_records, [:group_id, :year]
    add_index :time_records, [:group_id, :year, :type], unique: true
    TimeRecord.reset_column_information

    create_table :time_record_employee_pensums do |t|
      t.belongs_to :time_record, null: false
      t.decimal :paragraph_74, precision: 12, scale: 2
      t.decimal :not_paragraph_74, precision: 12, scale: 2
    end
  end
end
