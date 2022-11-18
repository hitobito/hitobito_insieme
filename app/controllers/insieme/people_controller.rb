# frozen_string_literal: true

#  Copyright (c) 2014-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module PeopleController
    def self.prepended(base) # rubocop:disable Metrics/MethodLength
      base.permitted_attrs +=
        [:salutation, :canton, :language, :correspondence_language,
         :number, :manual_number, :reference_person_number, :dossier, :ahv_number,
         :disabled_person_reference, :disabled_person_first_name,
         :disabled_person_last_name, :disabled_person_address,
         :disabled_person_zip_town, :disabled_person_zip_code,
         :disabled_person_town, :disabled_person_birthday,
         :newly_registered, :correspondence_general_label, :billing_general_label,
         :correspondence_course_label, :billing_course_label]

      # Permit person address fields
      Person::ADDRESS_TYPES.each do |prefix|
        %w(same_as_main).concat(Person::ADDRESS_FIELDS).each do |field|
          base.permitted_attrs << :"#{prefix}_#{field}"
        end
      end
    end

    def permitted_attrs
      p = super
      if entry.id == current_user.id
        p -= [:number, :manual_number, :reference_person_number, :dossier]
      end
      p
    end
  end
end
