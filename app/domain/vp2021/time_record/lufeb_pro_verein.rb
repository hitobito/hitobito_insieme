# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2021
  class TimeRecord::LufebProVerein
    attr_reader :year

    def initialize(year)
      @year = year
      @lufeb_data = {}
    end

    def vereine
      @vereine ||= Group.by_bsv_number.all
    end

    Data = Struct.new(:general, :specific, :promoting, :lufeb_grundlagen, :kurse_grundlagen)

    def lufeb_data_for(verein_id)
      @lufeb_data[verein_id] ||= Data.new(*time_records[verein_id])
    end

    private

    def time_records # rubocop:disable Metrics/MethodLength
      @time_records ||=
        ::TimeRecord
        .where(year: @year, type: [
                 'TimeRecord::EmployeeTime',
                 'TimeRecord::VolunteerWithVerificationTime'
               ])
        .group(:group_id)
        .select([
          'group_id',
          'SUM(total_lufeb_general) AS `general`',
          'SUM(total_lufeb_specific) AS `specific`',
          'SUM(total_lufeb_promoting) AS `promoting`',
          'SUM(lufeb_grundlagen) AS `lufeb_grundlagen`',
          'SUM(kurse_grundlagen) AS kurse_grundlagen'
        ].join(', '))
        .all
        .each_with_object({}) do |tr, memo|
          memo[tr.group_id] = [
            tr.general,
            tr.specific,
            tr.promoting,
            tr.lufeb_grundlagen,
            tr.kurse_grundlagen
          ]
        end
    end
  end
end
