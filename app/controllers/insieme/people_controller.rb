# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module PeopleController
    extend ActiveSupport::Concern

    included do
      ::PeopleController::QUERY_FIELDS << :number

      self.permitted_attrs +=
        [:salutation, :canton, :language, :correspondence_language,
         :number, :manual_number, :reference_person_number, :dossier, :ahv_number]

      # Permit person address fields
      Person::ADDRESS_TYPES.each do |prefix|
        %w(same_as_main).concat(Person::ADDRESS_FIELDS).each do |field|
          self.permitted_attrs << :"#{prefix}_#{field}"
        end
      end

      alias_method_chain :permitted_attrs, :self_update_check
    end

    def permitted_attrs_with_self_update_check
      p = permitted_attrs_without_self_update_check
      if entry.id == current_user.id
        p -= [:number, :manual_number, :reference_person_number, :dossier]
      end
      p
    end
  end
end
