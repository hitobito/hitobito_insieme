# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::GroupAbility
  extend ActiveSupport::Concern

  REPORTING_DACH_ROLES =  [Group::Dachverein::Geschaeftsfuehrung,
                           Group::Dachverein::Sekretariat,
                           Group::Dachverein::Adressverwaltung]

  REPORTING_REGIO_ROLES = [Group::Regionalverein::Geschaeftsfuehrung,
                           Group::Regionalverein::Sekretariat,
                           Group::Regionalverein::Adressverwaltung,
                           Group::Regionalverein::Controlling,
                           Group::ExterneOrganisation::Geschaeftsfuehrung,
                           Group::ExterneOrganisation::Sekretariat,
                           Group::ExterneOrganisation::Adressverwaltung,
                           Group::ExterneOrganisation::Controlling]


  included do
    on(Group) do
      permission(:layer_full).may(:reporting).if_dachverein_member
      permission(:any).may(:reporting).if_regionalverein_member_in_same_group

      general(:reporting).for_reporting_group
    end
  end

  def if_regionalverein_member_in_same_group
    roles = user_context.user.roles.select { |role| role.group_id == group.id }
    contains_any?(roles.collect(&:class), REPORTING_REGIO_ROLES)
  end

  def if_dachverein_member
    roles = user_context.user.roles
    contains_any?(roles.collect(&:class), REPORTING_DACH_ROLES)
  end

  def for_reporting_group
    group.reporting?
  end

end
