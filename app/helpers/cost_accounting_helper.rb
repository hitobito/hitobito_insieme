# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CostAccountingHelper
  def cost_accounting_input_fields(f, *fields)
    safe_join(fields) do |field|
      if report.editable_fields.include?(field.to_s)
        f.labeled_input_field(field, addon: t('global.currency'))
      end
    end
  end

  def cost_account_field_class(field)
    'subtotal' if %w(aufwand_ertrag_ko_re total).include?(field)
  end

  def cost_accounting_reports
    CostAccounting::Table::REPORTS.values
  end

  def base_time_record_group_path(group, _params = {})
    group_path(group) + '/time_record'
  end

  def reporting_nav(label, path, options = {})
    content_tag(:li, class: current_page?(path) && 'active') do
      link_to(label, path, options)
    end
  end
end
