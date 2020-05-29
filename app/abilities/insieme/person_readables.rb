# frozen_string_literal: true

#  Copyright (c) 2014-2020, insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::PersonReadables
  def contact_data_visible?
    super && (group.nil? || contact_data_layer_ids.include?(group.layer_group_id))
  end

  def contact_data_condition
    ['people.contact_data_visible = ? AND groups.layer_group_id IN (?)',
     true,
     contact_data_layer_ids]
  end

  private

  def contact_data_layer_ids
    user_context.layer_ids(user.groups_with_permission(:contact_data))
  end
end
