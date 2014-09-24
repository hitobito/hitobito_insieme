# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::EventAbility
  extend ActiveSupport::Concern

  included do
    on(Event) do
      permission(:any).may(:application_market).for_managed_events
    end
  end
end
