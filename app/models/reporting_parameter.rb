# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: reporting_parameters
#
#  id                                :integer          not null, primary key
#  year                              :integer          not null
#  vollkosten_le_schwelle1_blockkurs :decimal(12, 2)   not null
#  vollkosten_le_schwelle2_blockkurs :decimal(12, 2)   not null
#  vollkosten_le_schwelle1_tageskurs :decimal(12, 2)   default(0.0), not null
#  vollkosten_le_schwelle2_tageskurs :decimal(12, 2)   default(0.0), not null
#

class ReportingParameter < ActiveRecord::Base

  scope :list, -> { order(:year) }

  def self.for(year)
    return unless year
    where('year <= ?', year).order('year DESC').first
  end

  def to_s
    year
  end

end
