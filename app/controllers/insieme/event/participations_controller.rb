# frozen_string_literal: true
#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Event::ParticipationsController
    def self.prepended(base)
      base.permitted_attrs += [:disability, :multiple_disability, :wheel_chair,
                               person_attributes: additional_person_attributes]
    end

    private

    def permitted_attrs
      attrs = super
      if can?(:modify_internal_fields, entry)
        attrs += [:invoice_text, :invoice_amount]
      end
      attrs
    end

    private_class_method

    def self.additional_person_attributes
      person_attributes = [:id, :canton, :birthday, :ahv_number,
                           :address, :zip_code, :town, :country]

      Person::ADDRESS_TYPES.grep(/course/).each do |prefix|
        person_attributes << :"#{prefix}_same_as_main"
        Person::ADDRESS_FIELDS.each do |field|
          person_attributes << :"#{prefix}_#{field}"
        end
      end

      person_attributes
    end
  end
end
