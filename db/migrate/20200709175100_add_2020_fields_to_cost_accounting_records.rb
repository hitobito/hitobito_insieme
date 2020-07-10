class Add2020FieldsToCostAccountingRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :cost_accounting_records, :medien_und_publikationen, :decimal, precision: 12, scale: 2
  end
end
