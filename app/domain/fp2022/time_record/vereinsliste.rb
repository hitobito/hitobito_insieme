# frozen_string_literal: true

#  Copyright (c) 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2022
  class TimeRecord::Vereinsliste

    attr_reader :year, :type

    # type is one of
    # - TimeRecord::EmployeeTime
    # - TimeRecord::VolunteerWithVerificationTime
    # - TimeRecord::VolunteerWithoutVerificationTime
    def initialize(year, type)
      @year = year
      @type = type
    end

    def vereine
      @vereine ||=
        Group
        .without_deleted
        .where(type: [
          Group::Dachverein,
          Group::Regionalverein,
          Group::ExterneOrganisation
        ].collect(&:sti_name))
        .order_by_type
    end

    def time_record(verein)
      time_records[verein.id]
    end

    def time_records
      @time_records ||= ::TimeRecord.where(type: type, year: year).index_by(&:group_id)
    end

  end
end
