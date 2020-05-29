# frozen_string_literal: true
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

  validates_by_schema
  validates(*Cantons.short_names,
            numericality: { greater_than_or_equal_to: 0, allow_blank: true })


  def total
    Cantons.short_name_strings.inject(0) { |sum, c| sum + attributes[c].to_i }
  end

end
