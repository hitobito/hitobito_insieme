#  Copyright (c) 2014-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module EventDecorator
    def dates_full
      if model.is_a?(::Event::AggregateCourse)
        dates.first.start_at.year
      else
        super
      end
    end
  end
end
