# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Insieme
  module Export
    module Pdf
      module Labels
        extend ActiveSupport::Concern

        included do
          alias_method_chain :initialize, :address_type
          alias_method_chain :address, :type
        end

        def initialize_with_address_type(format, address_type = nil)
          initialize_without_address_type(format)
          @address_type = address_type if Person::ADDRESS_TYPES.include?(address_type.to_s)
        end

        def address_with_type(contactable)
          if contactable.is_a?(Person) && @address_type
            address_without_type(AddressProxy.new(contactable, @address_type))
          else
            address_without_type(contactable)
          end
        end

        class AddressProxy
          def initialize(person, address_type)
            @person = person
            @address_type = address_type
          end

          def full_name
            "#{first_name} #{last_name}".strip
          end

          def ignored_country?
            Countries.swiss?(country)
          end

          def respond_to?(name)
            @person.respond_to?("#{@address_type}_#{name}") || super
          end

          def method_missing(name, *args)
            if respond_to?(name)
              @person.send("#{@address_type}_#{name}")
            else
              super
            end
          end
        end
      end
    end
  end
end
