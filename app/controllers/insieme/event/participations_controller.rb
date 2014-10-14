# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Event::ParticipationsController
    extend ActiveSupport::Concern

    included do
      self.permitted_attrs += [person_attributes: [:id, :canton, :birthday, :address, :zip_code,
                                                   :town, :country,
                                                   :correspondence_course_same_as_main,
                                                   :correspondence_course_full_name,
                                                   :correspondence_course_company_name,
                                                   :correspondence_course_company,
                                                   :correspondence_course_address,
                                                   :correspondence_course_zip_code,
                                                   :correspondence_course_town,
                                                   :correspondence_course_country,
                                                   :billing_course_same_as_main,
                                                   :billing_course_full_name,
                                                   :billing_course_company_name,
                                                   :billing_course_company,
                                                   :billing_course_address,
                                                   :billing_course_zip_code,
                                                   :billing_course_town,
                                                   :billing_course_country]]

      alias_method_chain :assign_attributes, :check
      alias_method_chain :exporter, :check

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

    def exporter_with_check
      check? ? ::Export::Csv::People::ParticipationsComplete : exporter_without_check
    end

    # only roles with :modify_internal_fields permission are allowed to set those attributes
    def assign_attributes_with_check
      if model_params.present? && check?
        entry.internal_invoice_text = model_params.delete(:internal_invoice_text)
        entry.internal_invoice_amount = model_params.delete(:internal_invoice_amount)
      end

      assign_attributes_without_check
    end

    def check?
      can?(:modify_internal_fields, entry)
    end
  end
end
