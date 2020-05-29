# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020
  class TimeRecord::Report::EmployeeTime < TimeRecord::Report::Base

    def paragraph_74
      record.total_paragraph_74_pensum
    end

    def not_paragraph_74
      record.total_not_paragraph_74_pensum
    end

    def total
      record.total_pensum
    end

  end
end
