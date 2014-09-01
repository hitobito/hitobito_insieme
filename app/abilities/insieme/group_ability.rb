# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::GroupAbility
  extend ActiveSupport::Concern

  included do
    on(Group) do
      permission(:layer_full).may(:reporting).if_dachverein_member
      permission(:any).may(:reporting).if_regionalverein_member_in_same_group
    end
  end

  def if_regionalverein_member_in_same_group
    user_context.user.roles
      .select { |role| role.group_id == group.id  }
      .any? do |role|
        role?(role,
              Group::Regionalverein::Geschaeftsfuehrung,
              Group::Regionalverein::Sekretariat,
              Group::Regionalverein::Adressverwaltung,
              Group::Regionalverein::Controlling)
    end
  end

  def if_dachverein_member
    user_context.user.roles.any? do |role|
      role?(role,
            Group::Dachverein::Geschaeftsfuehrung,
            Group::Dachverein::Sekretariat,
            Group::Dachverein::Adressverwaltung)
    end
  end

  private

  def role?(role, *candiates)
    candiates.any? { |candiate| role.is_a?(candiate) }
  end

end
