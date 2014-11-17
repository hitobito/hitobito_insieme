# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module CourseReporting
  class CourseDays

    attr_reader :dates

    DAY = 1
    HALF_DAY = 0.5
    FOUR_HOURS = 60 * 60 * 4

    def initialize(event_dates)
      @dates = event_dates
    end

    def sum
      dates.inject(0) { |sum, date| sum + count(date) }
    end

    private

    def count(date)

      if !date.finish_at
        count(full_start(date))
      elsif multiple_days?(date)
        count(full_start(date)) + count(full_finish(date)) + days_in_between(date)
      else
        half_day?(date) ? HALF_DAY : DAY
      end
    end

    def multiple_days?(date)
      date.start_at.to_date != date.finish_at.to_date
    end

    def half_day?(date)
      start_at, finish_at = date.start_at, date.finish_at

      afternoon?(start_at) || !afternoon?(finish_at) || (finish_at - start_at) <= FOUR_HOURS
    end

    def days_in_between(date)
      date.duration.days - 2
    end

    def afternoon?(date)
      date.midnight + 12.hours + 30.minutes <= date
    end

    def full_start(date)
      Event::Date.new(start_at: date.start_at,
                      finish_at: date.start_at.end_of_day)
    end

    def full_finish(date)
      Event::Date.new(start_at: date.finish_at.midnight,
                      finish_at: date.finish_at)
    end

  end

end
