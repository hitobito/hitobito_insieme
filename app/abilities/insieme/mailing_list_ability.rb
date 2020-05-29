#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::MailingListAbility
  extend ActiveSupport::Concern

  included do
    on(::MailingList) do
      permission(:any).may(:index, :show).any_role_in_same_layer
      permission(:layer_and_below_read).may(:index, :show).in_same_layer_or_below
    end
  end

  def any_role_in_same_layer
    group && user_context.layer_ids(user_context.user.groups).include?(group.layer_group_id)
  end

end
