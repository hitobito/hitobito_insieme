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
         :number, :manual_number, :insieme_full_name]

      # Permit person address fields
      Person::ADDRESS_TYPES.each do |prefix|
        %w(same_as_main).concat(Person::ADDRESS_FIELDS).each do |field|
          self.permitted_attrs << :"#{prefix}_#{field}"
        end
      end

      alias_method_chain :permitted_params, :number_check
    end

    def permitted_params_with_number_check
      p = permitted_params_without_number_check
      if entry.id == current_user.id
        p.delete(:number)
        p.delete(:manual_number)
      end
      p
    end
  end
end
