# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::CourseRecordDecorator < ApplicationDecorator
  def absence_caption
    return translate(".absenzstunden") if duration_in_hours?

    translate(".absenztage")
  end

  def presence_caption
    return translate(".teilnehmer_stunden") if duration_in_hours?

    translate(".teilnehmer_tage")
  end

  def kursdauer_label
    return translate(".kursdauer_h") if duration_in_hours?

    translate(".kursdauer_d")
  end

  def duration_unit
    return I18n.t("global.hours_short") if duration_in_hours?

    I18n.t("global.days_short")
  end
end
