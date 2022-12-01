# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CostAccountingHelper
  include Featureperioden::Domain

  def cost_accounting_input_fields(f, *fields) # rubocop:disable Metrics/MethodLength,Naming/MethodParameterName
    course_fields = fp_class('CostAccounting::Report::CourseRelated')::COURSE_FIELDS
                    .keys.map(&:to_s)
    safe_join(fields) do |field|
      if report.editable_fields.include?(field.to_s)
        f.labeled_fp_input_field(field, addon: t('global.currency'))
      elsif report < fp_class('CostAccounting::Report::CourseRelated') && \
              course_fields.include?(field.to_s)
        # use tag to create field without a name.
        tag(:input,
            type: 'hidden',
            id: "cost_accounting_record_#{field}",
            value: table.value_of(report.key, field))
      end
    end
  end

  def cost_accounting_input_and_course_fields(f, *fields) # rubocop:disable Metrics/MethodLength,Naming/MethodParameterName,Metrics/AbcSize
    course_fields = fp_class('CostAccounting::Report::CourseRelated')::COURSE_FIELDS
                    .keys.map(&:to_s)
    safe_join(fields) do |field|
      if report.editable_fields.include?(field.to_s)
        f.labeled_fp_input_field(field, addon: t('global.currency'))
      elsif report < fp_class('CostAccounting::Report::CourseRelated') && \
              course_fields.include?(field.to_s)
        field_value = table.value_of(report.key, field) || 0.0
        [
          f.labeled_readonly_value(field, value: format_money(field_value)),
          # use tag to create field without a name.
          hidden_field_tag(nil, field_value, id: "cost_accounting_record_#{field}")
        ]
      end
    end
  end

  def cost_account_field_class(field)
    'subtotal' if %w(aufwand_ertrag_ko_re total).include?(field)
  end

  def cost_accounting_reports
    fp_class('CostAccounting::Table')::VISIBLE_REPORTS
  end

  def cost_accounting_report_header(field)
    I18n.translate(
      field,
      scope: [fp_i18n_scope, :headers],
      default: CostAccountingRecord.human_attribute_name(field)
    )
  end

  def base_time_record_group_path(group, _params = {})
    group_path(group) + '/time_record'
  end

  def reporting_nav(label, path, options = {})
    content_tag(:li, class: current_page?(path) && 'active') do
      link_to(label, path, options)
    end
  end

  def reporting_frozen?
    frozen = GlobalValue.reporting_frozen_until_year
    frozen && year <= frozen
  end

  def reporting_frozen_message
    if reporting_frozen?
      content_tag(:div, t('reporting.frozen_warning'), class: 'alert alert-warning')
    end
  end
end
