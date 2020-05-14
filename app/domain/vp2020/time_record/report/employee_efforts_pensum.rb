# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020
  class TimeRecord::Report::EmployeeEffortsPensum < TimeRecord::Report::Base

    self.kind = :controlling

    def paragraph_74
      if table.value_of('employee_time', 'paragraph_74').nonzero?
        table.value_of('employee_efforts', 'paragraph_74').to_d /
          table.value_of('employee_time', 'paragraph_74').to_d
      else
        0
      end
    end

  end
end
