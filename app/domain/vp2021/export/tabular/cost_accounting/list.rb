# frozen_string_literal: true

#  Copyright (c) 2020 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Vp2021::Export::Tabular::CostAccounting
  class List < Export::Tabular::Base
    include Vertragsperioden::Domain

    attr_accessor :year

    self.row_class = Export::Tabular::CostAccounting::Row
    self.auto_filter = false

    def initialize(list, group_name, year)
      @group_name = group_name
      @year = year
      @list = only_visible_reports(list)
      self.model_class = vp_class('CostAccounting::Report::Base')
      add_header_rows
    end

    def build_attribute_labels
      {}.tap do |labels|
        labels[:report] = human(:report)

        vp_class('CostAccounting::Table').fields.each do |field|
          labels[field.to_sym] = human(field)
        end
      end
    end

    private

    def only_visible_reports(reports)
      visible_report_keys = Vp2021::CostAccounting::Table::VISIBLE_REPORTS.map(&:key)

      reports.select do |report|
        visible_report_keys.include?(report.key)
      end
    end

    def human(field)
      I18n.t("activerecord.attributes.cost_accounting_record.#{field}")
    end

    def add_header_rows
      header_rows << []
      header_rows << title_header_values
      header_rows << []
      header_rows << combined_labels_row
    end

    def title_header_values
      row = Array.new(18)
      row[0] = @group_name
      row[1] = reporting_year
      row[14] = "#{I18n.t('global.printed')}: "
      row[15] = printed_at
      row
    end

    def combined_labels_row
      row = Array.new(18)
      row[5] = I18n.t('cost_accounting.index.gemeinkosten')
      row
    end

    def reporting_year
      "#{I18n.t('cost_accounting.index.reporting_year')}: #{@year}"
    end

    def printed_at
      I18n.l(Time.zone.today) + Time.zone.now.strftime(' %H:%M')
    end

  end
end
