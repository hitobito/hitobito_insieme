# frozen_string_literal: true
#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

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

  include Insieme::ReportingFreezable

  belongs_to :group

  validates_by_schema
  validates :report, uniqueness: { scope: [:group_id, :year], case_sensitive: false },
                     inclusion: CostAccounting::Table::REPORTS.collect(&:key)
  validate :assert_group_has_reporting

  scope :calculation_fields, -> { select(column_names - %w(aufteilung_kontengruppen)) }

  def report_class
    CostAccounting::Table::REPORTS.find { |r| r.key == report }
  end

  def to_s
    report_class.human_name
  end

  private

  def assert_group_has_reporting
    unless group.reporting?
      errors.add(:group_id, :is_not_allowed)
    end
  end

end
