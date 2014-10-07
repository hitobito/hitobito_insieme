# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Event::CourseRecordsHelper
  def kursart_label(art)
    t("activerecord.attributes.event/course_record.kursarten.#{art}")
  end

  def participant_field_with_suggestion(form, attr, suggestion)
    form.labeled_input_field(attr,
                             addon: t('global.persons_short'),
                             help_inline: muted(t('event.course_records.form.according_to_list',
                                                  count: f(suggestion))))
  end
end
