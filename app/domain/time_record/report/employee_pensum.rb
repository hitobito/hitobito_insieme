# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class TimeRecord::Report::EmployeePensum < TimeRecord::Report::Base

  def paragraph_74
    table.employee_pensum.paragraph_74
  end

  def not_paragraph_74
    table.employee_pensum.not_paragraph_74
  end

  def total
    table.employee_pensum.total
  end

end
