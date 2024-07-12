# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.
# == Schema Information
#
# Table name: global_values
#
#  id                          :integer          not null, primary key
#  default_reporting_year      :integer          not null
#  reporting_frozen_until_year :integer
#

class GlobalValue < ActiveRecord::Base
  delegate :clear_cache, to: :class

  validates_by_schema

  before_create :assert_no_other_records
  after_save :clear_cache

  class << self
    %w[default_reporting_year
      reporting_frozen_until_year].each do |attr|
      define_method(attr) do
        cached[attr]
      end
    end

    def cached
      Rails.cache.fetch(model_name.route_key) do
        first.try(:attributes) || {}
      end
    end

    def clear_cache
      Rails.cache.clear
      true
    end
  end

  def to_s
    self.class.model_name.human
  end

  private

  def assert_no_other_records
    errors.add(:base, :record_exists) if GlobalValue.exists?
  end
end
