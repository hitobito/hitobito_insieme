# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::GroupAbility
  extend ActiveSupport::Concern

  DACH_MANAGER_ROLES = Group::Dachverein.role_types.select do |r|
    r.permissions.include?(:layer_and_below_full)
  end

  REPORTING_DACH_ROLES  = DACH_MANAGER_ROLES + [Group::Dachverein::Controlling]

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
        may(:index_events, :'index_event/courses').
        any_role_in_same_layer_or_if_dachverein_manager_or_if_regionalverein

      permission(:any).may(:'index_event/aggregate_courses').in_same_group
      permission(:group_full).may(:'export_event/aggregate_courses').in_same_group
      permission(:group_and_below_full).may(:'export_event/aggregate_courses').in_same_group_or_below
      permission(:layer_read).
        may(:'index_event/aggregate_courses', :'export_event/aggregate_courses').
        in_same_layer
      permission(:layer_and_below_read).
        may(:'index_event/aggregate_courses', :'export_event/aggregate_courses').
        in_same_layer_or_below


      permission(:any).
        may(:index_mailing_lists).
        any_role_in_same_layer_or_if_dachverein_manager

      permission(:any).may(:deleted_subgroups).none
      permission(:layer_full).may(:deleted_subgroups).in_same_layer
      permission(:layer_and_below_full).may(:deleted_subgroups).in_same_layer_or_below

      permission(:contact_data).may(:index_people).contact_data_in_same_layer

      permission(:any).
        may(:reporting).
        if_dachverein_controlling_or_regionalverein_manager_in_same_group

      permission(:group_read).may(:statistics).in_same_group
      permission(:group_and_below_read).may(:statistics).in_same_group
      permission(:layer_read).may(:statistics).in_same_group
      permission(:layer_and_below_read).may(:statistics).in_same_group

      permission(:any).may(:controlling).if_dachverein_controlling

      general(:reporting).for_reporting_group
      general(:statistics).for_dachverein
      general(:controlling).for_dachverein
    end
  end

  def if_dachverein_controlling_or_regionalverein_manager_in_same_group
    if_dachverein_controlling ||
    if_regionalverein_manager_in_same_group
  end

  def if_regionalverein_manager_in_same_group
    roles = user_context.user.roles.select { |role| role.group_id == group.id }
    contains_any?(roles.collect(&:class), REPORTING_REGIO_ROLES)
  end

  def if_dachverein_manager
    roles = user_context.user.roles
    contains_any?(roles.collect(&:class), DACH_MANAGER_ROLES)
  end

  def if_dachverein_controlling
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

  def any_role_in_same_layer_or_if_dachverein_manager_or_if_regionalverein
    any_role_in_same_layer_or_if_dachverein_manager || if_regionalverein
  end

  def any_role_in_same_layer
    group && user_context.layer_ids(user_context.user.groups).include?(group.layer_group_id)
  end

  def contact_data_in_same_layer
    group &&
    user_context.layer_ids(user.groups_with_permission(:contact_data)).
                 include?(group.layer_group_id)
  end

  def if_group_in_hierarchy
    user_context.user.groups.collect(&:hierarchy).flatten.include?(group)
  end

  def if_regionalverein_and_not_external_member
    if_regionalverein &&
    user_context.user.groups.any? { |g| g.layer_group.is_a?(Group::Regionalverein) }
  end

  def if_regionalverein
    group.is_a?(Group::Regionalverein)
  end

  def for_dachverein
    group.is_a?(Group::Dachverein)
  end

  def for_reporting_group
    group.reporting?
  end

  def any_role_in_same_group_except_external_and_addressverwaltung
    user_context.user.roles.any? do |r|
      r.group.id == group.id && r.class.name.demodulize != 'External' &&
        r.class.name.demodulize != 'Adressverwaltung'
    end
  end

end
