# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.
# == Schema Information
#
# Table name: time_record_employee_pensums
#
#  id               :integer          not null, primary key
#  time_record_id   :integer          not null
#  paragraph_74     :decimal(12, 2)
#  not_paragraph_74 :decimal(12, 2)
#

class TimeRecord::EmployeePensum < ActiveRecord::Base
  belongs_to :time_record

  def total
    paragraph_74.to_d +
      not_paragraph_74.to_d
  end
end
