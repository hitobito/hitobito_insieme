# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::PersonAbility
  extend ActiveSupport::Concern

  included do
    on(Person) do
      permission(:contact_data).may(:show).other_with_contact_data_in_same_layer
    end
  end

  def other_with_contact_data_in_same_layer
    other_with_contact_data &&
    contains_any?(user_context.layer_ids(user.groups_with_permission(:contact_data)),
                  subject.layer_group_ids)
  end

end
