# frozen_string_literal: true

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2015::Export::Tabular::Events
  class AggregateCourse::ShortList < ShortList

    def title_header_values
      row = Array.new(18)
      row[0] = @group_name
      row[2] = reporting_year
      row[10] = document_title
      row[29] = "#{I18n.t('global.printed')}: "
      row[31] = printed_at
      row
    end

    def title
      I18n.t('activerecord.models.event/aggregate_course.other')
    end

  end
end
