# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


# == Schema Information
#
# Table name: event_general_cost_allocations
#
#  id                         :integer          not null, primary key
#  group_id                   :integer          not null
#  year                       :integer          not null
#  general_costs_blockkurs    :decimal(12, 2)
#  general_costs_tageskurs    :decimal(12, 2)
#  general_costs_semesterkurs :decimal(12, 2)
#  created_at                 :datetime
#  updated_at                 :datetime
#
class Event::GeneralCostAllocation < ActiveRecord::Base

  belongs_to :group

  validates :year, uniqueness: { scope: [:group_id] }
  validate :assert_group_has_reporting

  def to_s
    self.class.model_name.human
  end

  private

  def assert_group_has_reporting
    unless group.reporting?
      errors.add(:group_id, :is_not_allowed)
    end
  end
end
