# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Insieme::GroupAbility
  extend ActiveSupport::Concern

  included do
    on(Group) do
      # TODO: implement defined ability
      permission(:layer_full).may(:reporting).in_same_layer_or_below

    end
  end

end
