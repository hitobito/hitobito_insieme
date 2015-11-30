# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Event::CourseRecordsHelper

  def kursart_label(art)
    t("activerecord.attributes.event/course_record.kursarten.#{art}")
  end

  def gemeinkostenanteil_with_updated_at(record)
    string = format_money(record.gemeinkostenanteil)
    if record.gemeinkosten_updated_at
      string = safe_join([string,
                          ' &nbsp; &nbsp; '.html_safe,
                          t('event.course_records.form.updated_at',
                            date: format_attr(record, :gemeinkosten_updated_at))])
    end
    string
  end

  def zugeteilte_kategorie_with_info(record)
    if record.subventioniert
      record.zugeteilte_kategorie
    else
      safe_join([record.zugeteilte_kategorie.to_s,
                 ' &nbsp; &nbsp; '.html_safe,
                 t('event.course_records.form.info_not_subsidized')])
    end
  end

  def participant_field(form, attr, options = {})
    options.merge!(addon: t('global.persons_short')) unless options[:addon]
    form.labeled_input_field(attr, options)
  end

  def participant_field_with_suggestion(form, attr, suggestion, options = {})
    if event_may_have_participants?
      help_text = t('event.course_records.form.according_to_list', count: f(suggestion))
      options[:help_inline] = muted(help_text)
    end
    participant_field(form, attr, options)
  end

  def format_general_cost_allowance_percent(allowance)
    if allowance
      format_percent(allowance * 100)
    else
      ''
    end
  end

  def participant_readonly_value_with_suggestion(form, attr, value, suggestion, options = {})
    options[:value] = value
    if event_may_have_participants?
      help_text = t('event.course_records.form.according_to_list', count: suggestion)
      options[:help_inline] = help_text
    end
    form.labeled_readonly_value(attr, options)
  end

  def kursdauer_field(form, attr)
    options = {}
    options[:addon] = entry.duration_unit
    options[:label] = entry.kursdauer_label
    if event_may_have_participants?
      options[:help_inline] = kursdauer_help_inline
    end
    participant_field(form, attr, options)
  end

  def event_may_have_participants?
    entry.event.class.role_types.present?
  end

  private
  def kursdauer_help_inline
    duration = entry.sk? ? @numbers.duration_hours : @numbers.duration_days
    help_text = t('event.course_records.form.according_to_course_dates',
                duration: number_with_precision(
                duration, precision: 1, delimiter: t('number.format.delimiter'))
                )
    muted(help_text.html_safe)
  end

end
