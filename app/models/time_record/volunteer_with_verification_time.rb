# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class TimeRecord::VolunteerWithVerificationTime < TimeRecord

  before_save :update_lufeb_subtotals

  private

  def update_lufeb_subtotals
    calculate_total_lufeb_general!
    calculate_total_lufeb_private!
    calculate_total_lufeb_specific!
    calculate_total_lufeb_promoting!
  end

end
