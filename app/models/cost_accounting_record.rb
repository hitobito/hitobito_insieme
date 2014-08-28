class CostAccountingRecord < ActiveRecord::Base

  belongs_to :group

  validates :report, uniqueness: { scope: [:group_id, :year] },
                     inclusion: CostAccounting::Table::REPORTS.collect(&:key)

  scope :calculation_fields, -> { select(column_names - %w(aufteilung_kostengruppe)) }

end