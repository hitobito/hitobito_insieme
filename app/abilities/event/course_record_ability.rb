#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::CourseRecordAbility < AbilityDsl::Base

  include AbilityDsl::Constraints::Event

  on(Event::CourseRecord) do
    permission(:any).may(:update).for_reporting_or_controlling_events
    permission(:group_full).may(:update).in_same_group
    permission(:group_and_below_full).may(:update).in_same_group_or_below
    permission(:layer_full).may(:update).in_same_layer
    permission(:layer_and_below_full).may(:update).in_same_layer_or_below

    general(:update).for_reportable_event
  end

  def for_reportable_event
    event.reportable?
  end

  def for_reporting_or_controlling_events
    permission_in_event?(:reporting) || controller_in_group?
  end

  private

  def event
    subject.event
  end

  def controller_in_group?
    event_group = event.groups.first

    if event_group.class.const_defined?('Controlling')
      user_context.user.roles.
        select { |role| role.group_id == event_group.id }.
        any? { |role| role.is_a?(event_group.class.const_get('Controlling')) }
    end
  end
end
