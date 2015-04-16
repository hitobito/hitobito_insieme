# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class TimeRecord::Report::VolunteerWithVerificationTime < TimeRecord::Report::Base

  def paragraph_74
    table.volunteer_with_verification_time.total_paragraph_74_pensum
  end

  def not_paragraph_74
    table.volunteer_with_verification_time.total_not_paragraph_74_pensum
  end

  def total
    table.volunteer_with_verification_time.total_pensum
  end

end
