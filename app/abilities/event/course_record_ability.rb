# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::CourseRecordAbility < AbilityDsl::Base

  include AbilityDsl::Constraints::Event

  on(Event::CourseRecord) do
    permission(:any).may(:update).for_managed_events
    permission(:group_full).may(:update).in_same_group
    permission(:layer_full).may(:update).in_same_layer_or_below

    general(:update).for_course_event
  end

  def for_course_event
    event.class == Event::Course
  end

  private

  def event
    subject.event
  end
end
