# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::EventAbility
  extend ActiveSupport::Concern

  included do
    on(Event) do
      permission(:any).may(:read).participating_or_in_regionalverein_or_any_role_in_same_layer
      permission(:layer_and_below_read).may(:read).in_same_layer_or_below

      permission(:any).may(:application_market).for_participations_full_events
    end
  end

  def participating_or_in_regionalverein_or_any_role_in_same_layer
    if event.is_a?(Event::AggregateCourse)
      contains_any?(user_context.user.groups.collect(&:id),
                    event.groups.collect(&:id))
    else
      user_context.participations.collect(&:event_id).include?(event.id) ||
      event.groups.any? { |g| g.is_a?(Group::Regionalverein) } ||
      contains_any?(user_context.layer_ids(user_context.user.groups),
                    event.groups.collect(&:layer_group_id))
    end
  end

end
