# frozen_string_literal: true

#  Copyright (c) 2020-2022, Insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later. See
#  the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vertragsperioden
  class Dispatcher
    FAR_FUTURE_YEAR = 9999
    KNOWN_VP_BASE_YEARS = [2015, 2020, 2021].freeze

    def self.domain_classes(class_name)
      KNOWN_VP_BASE_YEARS.map { |vp| Dispatcher.new(vp).domain_class(class_name) }
    end

    def initialize(year)
      @year = year.to_i
    end

    def view_path
      Wagons.find('insieme').root / 'app' / 'views' / "vp#{determine}"
    end

    def domain_class(class_name)
      "Vp#{determine}::#{class_name}".constantize
    end

    def i18n_scope(scope)
      "vp#{determine}.#{scope}"
    end

    def supported?
      (2015..FAR_FUTURE_YEAR).include?(@year) # well, could be (2015...) in ruby 2.6+
    end

    def determine
      return 2015 unless supported? # the earliest year

      case @year
      when 2015..2019             then 2015
      when 2020..2020             then 2020
      when 2021...FAR_FUTURE_YEAR then 2021
      end
    end
  end
end
