# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Export::Xlsx::Events
  class ShortList < ::Export::Xlsx::Events::List

    TITLE = I18n.t('export/xlsx/events.title')

    self.style_class = Insieme::Export::Xlsx::Events::Style

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
      add_header_row
      add_header_row(title_header_values, style.style_title_header_row)
      add_header_row
    end

    def title_header_values
      row = Array.new(18)
      row[0] = @group_name
      row[3] = reporting_year
      row[12] = document_title
      row[29] = "#{I18n.t('global.printed')}: "
      row[30] = printed_at
      row
    end

    def document_title
      # translate
      str = ''
      str << I18n.t('event.lists.courses.xlsx_export_title')
      str << ': '
      str << self.class::TITLE
      str
    end

    def reporting_year
      str = ''
      str << I18n.t('cost_accounting.index.reporting_year')
      str << ': '
      str << @year.to_s
      str
    end

    def printed_at
      str = ''
      str << I18n.l(Time.zone.today)
      str << Time.zone.now.strftime(' %H:%M')
      str
    end

  end
end
