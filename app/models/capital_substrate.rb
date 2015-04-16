# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class CapitalSubstrate < ActiveRecord::Base

  belongs_to :group

  validates :year, uniqueness: { scope: [:group_id, :type] }
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
