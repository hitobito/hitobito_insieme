# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class TimeRecord::Report::EmployeePensum < TimeRecord::Report::Base

  def paragraph_74
    record.paragraph_74
  end

  def not_paragraph_74
    record.not_paragraph_74
  end

  def total
    record.total
  end

  private

  def record
    table.record('employee_time').employee_pensum
  end

end
