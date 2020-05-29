#  Copyright (c) 2012-2016, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020
  class TimeRecord::Vereinsliste

    attr_reader :year, :type

    def initialize(year, type)
      @year = year
      @type = type
    end

    def vereine
      @vereine ||=
        Group.
        without_deleted.
        where(type: [Group::Dachverein,
                     Group::Regionalverein,
                     Group::ExterneOrganisation].
                       collect(&:sti_name)).
      order_by_type
    end

    def time_record(verein)
      time_records[verein.id]
    end

    def time_records
      @time_records ||=
        ::TimeRecord.where(type: type, year: year).
        each_with_object({}) do |record, hash|
          hash[record.group_id] = record
        end
    end

  end
end
