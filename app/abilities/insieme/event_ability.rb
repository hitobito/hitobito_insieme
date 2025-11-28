# frozen_string_literal: true

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

      general(:update).reporting_not_frozen
      general(:destroy).reporting_not_frozen_and_at_least_one_group_not_deleted
    end
  end

  def participating_or_in_regionalverein_or_any_role_in_same_layer
    if event.is_a?(Event::AggregateCourse)
      in_same_group
    else
      participating || in_regionalverein || in_same_layer
    end
  end

  def reporting_not_frozen
    !event.is_a?(Event::Reportable) || !event.reporting_frozen?
  end

  def reporting_not_frozen_and_at_least_one_group_not_deleted
    reporting_not_frozen && at_least_one_group_not_deleted
  end

  private

  def in_regionalverein
    event.groups.any? { |g| g.is_a?(Group::Regionalverein) }
  end
end
