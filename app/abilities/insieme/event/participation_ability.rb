#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Event::ParticipationAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Participation) do
      permission(:any).may(:modify_internal_fields).for_participations_full_events
      permission(:layer_full).may(:modify_internal_fields).in_same_layer
      permission(:layer_and_below_full).may(:modify_internal_fields).in_same_layer
    end
  end
end
