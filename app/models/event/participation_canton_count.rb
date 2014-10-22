# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: event_participation_canton_counts
#
#  id    :integer          not null, primary key
#  ag    :integer
#  ai    :integer
#  ar    :integer
#  be    :integer
#  bl    :integer
#  bs    :integer
#  fr    :integer
#  ge    :integer
#  gl    :integer
#  gr    :integer
#  ju    :integer
#  lu    :integer
#  ne    :integer
#  nw    :integer
#  ow    :integer
#  sg    :integer
#  sh    :integer
#  so    :integer
#  sz    :integer
#  tg    :integer
#  ti    :integer
#  ur    :integer
#  vd    :integer
#  vs    :integer
#  zg    :integer
#  zh    :integer
#  other :integer
#

class Event::ParticipationCantonCount < ActiveRecord::Base
  has_one :course_record_as_challenged_canton_count, foreign_key: :challenged_canton_count_id,
                                                     class_name: 'Event::CourseRecord'
  has_one :course_record_as_affiliated_canton_count, foreign_key: :affiliated_canton_count_id,
                                                     class_name: 'Event::CourseRecord'

  def total
    ag.to_i + ai.to_i + ar.to_i + be.to_i + bl.to_i + bs.to_i + fr.to_i +
      ge.to_i + gl.to_i + gr.to_i + ju.to_i + lu.to_i + ne.to_i + nw.to_i + ow.to_i +
      sg.to_i + sh.to_i + so.to_i + sz.to_i + tg.to_i + ti.to_i + ur.to_i + vd.to_i +
      vs.to_i + zg.to_i + zh.to_i + other.to_i
  end
end
