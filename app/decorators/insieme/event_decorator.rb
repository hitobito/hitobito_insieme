# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module EventDecorator
    extend ActiveSupport::Concern

    included do
      alias_method_chain :dates_full, :year
    end

    def dates_full_with_year
      if model.is_a?(::Event::AggregateCourse)
        dates.first.start_at.year
      else
        dates_full_without_year
      end
    end
  end
end
