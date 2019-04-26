# encoding: utf-8

#  Copyright (c) 2014, Insieme Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Event::RegisterController

  extend ActiveSupport::Concern

  included do
    alias_method_chain :save_entry, :role
  end

  def save_entry_with_role
    if save_entry_without_role
      role = external_role_class.new
      role.group = group.layer_group
      role.person = entry.person
      role.save!
      entry.person.roles << role
      true
    end
  end

  def external_role_class
    "#{group.layer_group.class}::External".constantize
  end
end
