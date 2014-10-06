# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: cost_accounting_parameters
#
#  id      :integer          not null, primary key
#  year    :integer          not null
#  kat1_bk :integer          not null
#  kat2_tk :integer          not null
#

class CostAccountingParameter < ActiveRecord::Base

  validates :year, uniqueness: true

  scope :list, -> { order(:year) }

  def self.previous
    list.where('year < ?',Time.zone.now.year).last
  end

  def to_s
    ''
  end

end
