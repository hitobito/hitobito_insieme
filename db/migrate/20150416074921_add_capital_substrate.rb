# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AddCapitalSubstrate < ActiveRecord::Migration
  def change
    create_table :capital_substrates do |t|
      t.belongs_to :group, null: false
      t.integer :year, null: false

      t.decimal :organization_capital, precision: 12, scale: 2
      t.decimal :fund_building, precision: 12, scale: 2

      t.timestamps
    end

    add_column :reporting_parameters, :capital_substrate_exemption, :decimal,
               precision: 12, scale: 2
    ReportingParameter.update_all(capital_substrate_exemption: 200_000)
    change_column :reporting_parameters, :capital_substrate_exemption, :decimal,
                  null: false, precision: 12, scale: 2
    ReportingParameter.reset_column_information
  end
end
