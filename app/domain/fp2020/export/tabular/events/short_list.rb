# frozen_string_literal: true

#  Copyright (c) 2014-2020 Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2020::Export::Tabular::Events
  class ShortList < ::Export::Tabular::Events::List
    def initialize(list, group_name, year)
      @group_name = group_name
      @year = year
      @list = list
      add_header_rows
    end

    private

    def build_attribute_labels
      super.tap { |labels| }
    end

    def add_header_rows
      header_rows << []
      header_rows << title_header_values
      header_rows << []
    end

    def title_header_values
      row = Array.new(30)
      row[0] = @group_name
      row[3] = reporting_year
      row[12] = document_title
      row[29] = "#{I18n.t("global.printed")}: "
      row[30] = printed_at
      row
    end

    def document_title
      "#{I18n.t("event.lists.courses.xlsx_export_title")}: #{title}"
    end

    def title
      I18n.t("export/tabular/events.title")
    end

    def reporting_year
      "#{I18n.t("cost_accounting.index.reporting_year")}: #{@year}"
    end

    def printed_at
      I18n.l(Time.zone.today) + Time.zone.now.strftime(" %H:%M")
    end
  end
end
