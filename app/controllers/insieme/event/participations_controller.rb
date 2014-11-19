# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Event::ParticipationsController
    extend ActiveSupport::Concern

    included do
      PERSON_ATTRIBUTES = [:id, :canton, :birthday, :ahv_number,
                           :address, :zip_code, :town, :country]

      Person::ADDRESS_TYPES.grep(/course/).each do |prefix|
        PERSON_ATTRIBUTES << :"#{prefix}_same_as_main"
        Person::ADDRESS_FIELDS.each do |field|
          PERSON_ATTRIBUTES << :"#{prefix}_#{field}"
        end
      end

      self.permitted_attrs += [:disability, :multiple_disability, :wheel_chair,
                               person_attributes: PERSON_ATTRIBUTES]

      alias_method_chain :permitted_attrs, :internal

      before_render_show :load_grouped_active_membership_roles
    end

    private

    def load_grouped_active_membership_roles
      return if cannot?(:show_details, entry)

      active_memberships = entry.person.roles.includes(:group).
                                              joins(:group).
                                              where(groups: { type: ::Group::Aktivmitglieder })
      @grouped_active_membership_roles = Hash.new { |h, k| h[k] = [] }
      active_memberships.each do |role|
        @grouped_active_membership_roles[role.group] << role
      end
    end

    def permitted_attrs_with_internal
      attrs = permitted_attrs_without_internal
      if can?(:modify_internal_fields, entry)
        attrs += [:invoice_text, :invoice_amount]
      end
      attrs
    end

  end
end
