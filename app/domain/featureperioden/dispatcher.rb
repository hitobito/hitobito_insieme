# frozen_string_literal: true

#  Copyright (c) 2020-2022, Insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later. See
#  the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Featureperioden
  class Dispatcher
    KNOWN_BASE_YEARS = [2015, 2020, 2022, 2024].freeze

    def self.domain_classes(class_name)
      KNOWN_BASE_YEARS.map { |fp| Dispatcher.new(fp).domain_class(class_name) }
    end

    def initialize(year)
      @year = year.to_i
    end

    def view_path
      Wagons.find("insieme").root / "app" / "views" / "fp#{determine}"
    end

    def domain_class(class_name)
      "Fp#{determine}::#{class_name}".constantize
    end

    def i18n_scope(scope)
      "fp#{determine}.#{scope}"
    end

    def supported?
      (KNOWN_BASE_YEARS.first..).cover?(@year)
    end

    def determine
      return KNOWN_BASE_YEARS.last if @year >= KNOWN_BASE_YEARS.last # the current period
      return KNOWN_BASE_YEARS.first unless supported? # the earliest year

      KNOWN_BASE_YEARS.each_cons(2) do |period, next_period|
        return period if (period...next_period).cover? @year
      end
    end
  end
end
