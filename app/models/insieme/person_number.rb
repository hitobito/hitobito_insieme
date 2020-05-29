# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::PersonNumber
  extend ActiveSupport::Concern

  included do
    AUTOMATIC_NUMBER_RANGE = 100_000...1_000_000

    before_validation :generate_automatic_number

    validate :allowed_number_range
  end

  def manual_number=(value)
    @manual_number =
      case value
      when '0', 0, false, nil then false
      else true
      end
  end

  def manual_number
    if @manual_number.nil? && number?
      @manual_number = !number_in_automatic_range?
    end
    @manual_number
  end

  private

  def allowed_number_range
    if number_in_automatic_range? && manual_number
      add_number_error(:manual_number_in_automatic_range)
    elsif !number_in_automatic_range? && !manual_number
      add_number_error(:automatic_number_in_manual_range)
    end
  end

  def add_number_error(key)
    errors.add(:number,
               key,
               lower: AUTOMATIC_NUMBER_RANGE.first,
               upper: AUTOMATIC_NUMBER_RANGE.last)
  end

  def generate_automatic_number
    unless manual_number
      self.restore_number!
      unless number_in_automatic_range?
        self.number = self.class.next_automatic_number
      end
    end
  end

  def number_in_automatic_range?
    AUTOMATIC_NUMBER_RANGE.cover?(number)
  end

  module ClassMethods
    def next_automatic_number
      p = Person.select(:number).
                 where(number: AUTOMATIC_NUMBER_RANGE).
                 order('number DESC').
                 first
      p ? p.number + 1 : AUTOMATIC_NUMBER_RANGE.first
    end
  end
end
