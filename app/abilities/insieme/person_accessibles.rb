# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::PersonAccessibles
  extend ActiveSupport::Concern

  included do
    alias_method_chain :group_contact_data_visible?, :same_layer
    alias_method_chain :contact_data_condition, :same_layer
  end

  def group_contact_data_visible_with_same_layer?
    group_contact_data_visible_without_same_layer? &&
    contact_data_layer_ids.include?(group.layer_group_id)
  end

  def contact_data_condition_with_same_layer
    ['people.contact_data_visible = ? AND groups.layer_group_id IN (?)',
     true,
     contact_data_layer_ids]
  end

  private

  def contact_data_layer_ids
    user_context.layer_ids(user.groups_with_permission(:contact_data))
  end
end
