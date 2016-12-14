# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export::Xlsx::CostAccounting
  class List < Export::Xlsx::Base

    self.model_class = ::CostAccounting::Report::Base
    self.row_class = Export::Xlsx::CostAccounting::Row
    self.style_class = Export::Xlsx::CostAccounting::Style

    def initialize(list, group_name, year)
      @group_name = group_name
      @year = year
      @list = list
      add_header_rows
    end

    def build_attribute_labels
      {}.tap do |labels|
        labels[:report] = human(:report)

        ::CostAccounting::Report::Base::FIELDS.each do |field|
          labels[field.to_sym] = human(field)
        end
      end
    end

    private

    def human(field)
      I18n.t("activerecord.attributes.cost_accounting_record.#{field}")
    end

    def add_header_rows
      add_header_row
      add_header_row(title_header_values, style.style_title_header_row)
      add_header_row
    end

    def title_header_values
      row = Array.new(18)
      row[0] = @group_name
      row[1] = reporting_year
      row[14] = "#{I18n.t('global.printed')}: "
      row[15] = printed_at
      row
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
