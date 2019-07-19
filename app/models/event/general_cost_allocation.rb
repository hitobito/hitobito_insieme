# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


# == Schema Information
#
# Table name: event_general_cost_allocations
#
#  id                          :integer          not null, primary key
#  group_id                    :integer          not null
#  year                        :integer          not null
#  general_costs_blockkurse    :decimal(12, 2)
#  general_costs_tageskurse    :decimal(12, 2)
#  general_costs_semesterkurse :decimal(12, 2)
#  general_costs_treffpunkte   :decimal(12, 2)
#  created_at                  :datetime
#  updated_at                  :datetime
#
class Event::GeneralCostAllocation < ActiveRecord::Base

  include Insieme::ReportingFreezable

  belongs_to :group

  validates_by_schema
  validates :year, uniqueness: { scope: [:group_id] }
  validate :assert_group_has_reporting

  def to_s
    self.class.model_name.human
  end

  def general_costs(leistungskategorie)
    case leistungskategorie
    when 'bk' then general_costs_blockkurse
    when 'tk' then general_costs_tageskurse
    when 'sk' then general_costs_semesterkurse
    when 'tp' then general_costs_treffpunkte
    else fail ArgumentError
    end
  end

  def total_costs(leistungskategorie)
    total_costs_by_lk[leistungskategorie]
  end

  def general_costs_allowance(leistungskategorie)
    @general_costs_allowances ||= {}
    @general_costs_allowances.fetch(leistungskategorie) do
      calculate_general_costs_allowance(leistungskategorie)
    end
  end

  def considered_course_records(subventioniert = true)
    Event::CourseRecord.joins(event: :events_groups).
                        where(subventioniert: subventioniert,
                              year: year,
                              events_groups: { group_id: group.id })
  end

  private

  def total_costs_by_lk
    @total_costs ||= considered_course_records.group('events.leistungskategorie').
                                               sum(:direkter_aufwand)
  end

  def calculate_general_costs_allowance(leistungskategorie)
    costs = total_costs(leistungskategorie)
    if costs && costs > 0
      general_costs(leistungskategorie).to_d / costs
    end
  end

  def assert_group_has_reporting
    unless group.reporting?
      errors.add(:group_id, :is_not_allowed)
    end
  end
end
