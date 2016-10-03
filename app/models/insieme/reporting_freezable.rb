# encoding: utf-8

#  Copyright (c) 2012-2016, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::ReportingFreezable

  extend ActiveSupport::Concern

  included do
    validate :assert_year_not_frozen

    before_destroy :protect_if_year_frozen
  end

  private

  def assert_year_not_frozen
    frozen = GlobalValue.reporting_frozen_until_year
    if frozen
      if year <= frozen || (year_changed? && year_was && year_was <= frozen)
        errors.add(:year, :reporting_frozen)
      end
    end
  end

  def protect_if_year_frozen
    assert_year_not_frozen
    errors.blank?
  end

end
