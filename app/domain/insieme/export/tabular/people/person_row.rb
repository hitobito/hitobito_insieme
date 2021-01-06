# frozen_string_literal: true

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Export::Tabular::People
  module PersonRow

    extend ActiveSupport::Concern

    def reference_person_first_name
      entry.reference_person&.first_name
    end

    def reference_person_last_name
      entry.reference_person&.last_name
    end

    def reference_person_address
      entry.reference_person&.address
    end

    def reference_person_zip_code
      entry.reference_person&.zip_code
    end

    def reference_person_town
      entry.reference_person&.town
    end

    def reference_person_active_membership_roles
      grouped_roles = entry.reference_person&.grouped_active_membership_roles
      if grouped_roles.present?
        grouped_roles.map do |group, roles|
          group.with_layer.join(' / ') + ': ' + roles.join(', ')
        end.join('; ')
      end
    end

    def reference_person_additional_information
      entry.reference_person&.additional_information
    end

    Person::ADDRESS_TYPES.each do |type|
      define_method("#{type}_country") do
        entry.send("#{type}_country_label")
      end
    end

  end
end
