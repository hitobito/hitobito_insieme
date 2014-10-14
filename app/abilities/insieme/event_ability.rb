# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::EventAbility
  extend ActiveSupport::Concern

  included do
    on(Event) do
      permission(:any).may(:read).participating_or_any_role_in_same_layer_or_in_regionalverein
      permission(:layer_and_below_read).may(:read).in_same_layer_or_below

      permission(:any).may(:application_market).for_participations_full_events
    end
  end

  def participating_or_any_role_in_same_layer_or_in_regionalverein
    user_context.participations.collect(&:event_id).include?(event.id) ||
    contains_any?(user_context.layer_ids(user_context.user.groups),
                  event.groups.collect(&:layer_group_id)) ||
    in_regionalverein
  end

  def in_regionalverein
    event.groups.map { |g| g.is_a?(Group::Regionalverein) }.any?
  end
end
