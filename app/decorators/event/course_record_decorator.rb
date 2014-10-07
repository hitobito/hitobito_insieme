# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::CourseRecordDecorator < ApplicationDecorator

  def absence_caption
    translate(sk? && '.absenzstunden' || '.absenztage')
  end

  def presence_caption
    translate(sk? && '.teilnehmer_stunden' || '.teilnehmer_tage')
  end

  def kursdauer_label
    translate(sk? && '.kursdauer_h' || '.kursdauer_d')
  end

  def duration_unit
    I18n.t(sk? && 'global.hours_short' || 'global.days_short')
  end

end
