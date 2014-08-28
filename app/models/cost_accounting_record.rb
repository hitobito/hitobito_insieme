# == Schema Information
#
# Table name: cost_accounting_records
#
#  id                          :integer          not null, primary key
#  group_id                    :integer          not null
#  year                        :integer          not null
#  report                      :string(255)      not null
#  aufwand_ertrag_fibu         :decimal(12, 2)
#  abgrenzung_fibu             :decimal(12, 2)
#  abgrenzung_dachorganisation :decimal(12, 2)
#  raeumlichkeiten             :decimal(12, 2)
#  verwaltung                  :decimal(12, 2)
#  beratung                    :decimal(12, 2)
#  treffpunkte                 :decimal(12, 2)
#  blockkurse                  :decimal(12, 2)
#  tageskurse                  :decimal(12, 2)
#  jahreskurse                 :decimal(12, 2)
#  lufeb                       :decimal(12, 2)
#  mittelbeschaffung           :decimal(12, 2)
#  aufteilung_kontengruppen    :text
#

class CostAccountingRecord < ActiveRecord::Base

  belongs_to :group

  validates :report, uniqueness: { scope: [:group_id, :year] },
                     inclusion: CostAccounting::Table::REPORTS.keys
  validate :assert_group_has_reporting

  scope :calculation_fields, -> { select(column_names - %w(aufteilung_kostengruppe)) }

  def report_class
    CostAccounting::Table::REPORTS[report]
  end

  private

  def assert_group_has_reporting
    unless [Group::Dachverein, Group::Regionalverein].include?(group.class)
      errors.add(:group_id, :is_not_allowed)
    end
  end

end
