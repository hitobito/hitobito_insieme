# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module CourseReporting
  class CourseDays

    attr_reader :dates

    NOON = 12.hours + 30.minutes
    HALF_DAY_HOURS = 4.hours

    def initialize(event_dates)
      @dates = event_dates
    end

    def sum
      dates.sum { |date| count_days(date) }
    end

    private

    def count_days(date)
      if !date.finish_at
        count_days(full_start(date))
      elsif multiple_days?(date)
        count_days(full_start(date)) + count_days(full_finish(date)) + days_in_between(date)
      else
        half_day?(date) ? 0.5 : 1
      end
    end

    def multiple_days?(date)
      date.start_at.to_date != date.finish_at.to_date
    end

    def half_day?(date)
      afternoon?(date.start_at) ||
      !afternoon?(date.finish_at) ||
      (date.finish_at - date.start_at) <= HALF_DAY_HOURS
    end

    def days_in_between(date)
      date.duration.days - 2
    end

    def afternoon?(date)
      date.midnight + NOON <= date
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
