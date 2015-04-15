# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class TimeRecord::EmployeeTime < TimeRecord

  has_one :employee_pensum, foreign_key: :time_record_id, dependent: :destroy,
          inverse_of: :time_record
  accepts_nested_attributes_for :employee_pensum

  before_save :update_lufeb_subtotals

  private

  def update_lufeb_subtotals
    calculate_total_lufeb_general!
    calculate_total_lufeb_private!
    calculate_total_lufeb_specific!
    calculate_total_lufeb_promoting!
  end

end
