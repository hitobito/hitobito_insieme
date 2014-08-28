
module Insieme::GroupAbility
  extend ActiveSupport::Concern

  included do
    on(Group) do
      # TODO: implement defined ability
      permission(:layer_full).may(:reporting).in_same_layer_or_below

    end
  end

end
