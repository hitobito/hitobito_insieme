#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020
  class TimeRecord::Report::EmployeePensum < TimeRecord::Report::Base

    delegate :paragraph_74, to: :record

    delegate :not_paragraph_74, to: :record

    delegate :total, to: :record

    private

    def record
      table.record('employee_time').employee_pensum ||
        table.record('employee_time').build_employee_pensum
    end

  end
end
