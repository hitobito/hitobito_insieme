# frozen_string_literal: true

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Fp2015::Export::Tabular::CostAccounting
  class List < Export::Tabular::Base
    include Featureperioden::Domain

    attr_accessor :year

    self.row_class = Export::Tabular::CostAccounting::Row
    self.auto_filter = false

    def initialize(list, group_name, year)
      @group_name = group_name
      @year = year
      @list = list
      self.model_class = fp_class('CostAccounting::Report::Base')
      add_header_rows
    end

    def build_attribute_labels
      {}.tap do |labels|
        labels[:report] = human(:report)

        fp_class('CostAccounting::Table').fields.each do |field|
          labels[field.to_sym] = human(field)
        end
      end
    end

    private

    def human(field)
      I18n.t("activerecord.attributes.cost_accounting_record.#{field}")
    end

    def add_header_rows
      header_rows << []
      header_rows << title_header_values
      header_rows << []
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
      "#{I18n.t('cost_accounting.index.reporting_year')}: #{@year}"
    end

    def printed_at
      I18n.l(Time.zone.today) + Time.zone.now.strftime(' %H:%M')
    end

  end
end
