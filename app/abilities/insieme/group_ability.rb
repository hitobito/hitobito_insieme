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
      permission(:any).
        may(:read).
        any_role_in_same_layer_or_layer_group_or_if_dachverein_manager

      permission(:any).
        may(:index_events, :index_mailing_lists).
        any_role_in_same_layer_or_if_dachverein_manager

      permission(:any).may(:deleted_subgroups).none
      permission(:layer_and_below_full).may(:deleted_subgroups).in_same_layer_or_below

      permission(:contact_data).may(:index_people).contact_data_in_same_layer

      permission(:layer_full).may(:create, :destroy).none

      permission(:any).may(:reporting).if_regionalverein_manager_in_same_group
      permission(:layer_and_below_full).may(:reporting).in_same_layer_or_below

      general(:reporting).for_reporting_group
    end
  end

  def if_regionalverein_manager_in_same_group
    roles = user_context.user.roles.select { |role| role.group_id == group.id }
    contains_any?(roles.collect(&:class), REPORTING_REGIO_ROLES)
  end

  def if_dachverein_manager
    roles = user_context.user.roles
    contains_any?(roles.collect(&:class), REPORTING_DACH_ROLES)
  end

  def any_role_in_same_layer_or_layer_group_or_if_dachverein_manager
    any_role_in_same_layer ||
    if_dachverein_manager ||
    if_regionalverein_and_not_external_member ||
    if_group_in_hierarchy
  end

  def any_role_in_same_layer_or_if_dachverein_manager
    any_role_in_same_layer || if_dachverein_manager
  end

  def in_same_layer_or_if_dachverein_manager
    in_same_layer || if_dachverein_manager
  end

  def any_role_in_same_layer
    group && user_context.layer_ids(user_context.user.groups).include?(group.layer_group_id)
  end

  def contact_data_in_same_layer
    group &&
    user_context.layer_ids(user.groups_with_permission(:contact_data)).
                 include?(group.layer_group_id)
  end

  def if_dachverein_manager_except_permission_giving
    if_dachverein_manager && except_permission_giving
  end

  def if_group_in_hierarchy
    user_context.user.groups.collect { |g| g.hierarchy }.flatten.include?(group)
  end

  def if_regionalverein_and_not_external_member
    subject.is_a?(Group::Regionalverein) &&
    user_context.user.groups.any? { |g| g.layer_group.is_a?(Group::Regionalverein) }
  end

  def for_reporting_group
    group.reporting?
  end

end
