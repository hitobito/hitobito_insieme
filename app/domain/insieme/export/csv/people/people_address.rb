# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Export
    module Csv
      module People
        module PeopleAddress
          extend ActiveSupport::Concern

          included do
            alias_method_chain :person_attributes, :insieme_attrs
          end

          def person_attributes_with_insieme_attrs
            person_attributes_without_insieme_attrs + additional_addresses_attributes
          end

          def additional_addresses_attributes
            attrs = [:insieme_full_name, :number, :salutation]
            Person::ADDRESS_TYPES.each do |prefix|
              Person::ADDRESS_FIELDS.each do |field|
                attrs << :"#{prefix}_#{field}"
              end
            end
            attrs
          end

        end
      end
    end
  end
end
