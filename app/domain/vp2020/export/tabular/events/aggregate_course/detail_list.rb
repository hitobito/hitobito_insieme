# frozen_string_literal: true

#  Copyright (c) 2014-2020 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020::Export::Tabular::Events
  class AggregateCourse::DetailList < DetailList

    def title_header_values
      row = Array.new(35)
      row[0] = @group_name
      row[2] = reporting_year
      row[10] = document_title
      row[27] = "#{I18n.t('global.printed')}: "
      row[30] = printed_at
      row
    end

    def title
      I18n.t('activerecord.models.event/aggregate_course.other')
    end

    # rubocop:disable Layout/EmptyLineBetweenDefs
    def add_date_labels(_labels); end
    def add_contact_labels(_labels); end
    def add_additional_labels(_labels); end
    def add_count_labels(_labels); end
    # rubocop:enable Layout/EmptyLineBetweenDefs

  end
end
