# frozen_string_literal: true

#  Copyright (c) 2014-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Export
    module Pdf
      module Labels
        def initialize(format, address_type = nil)
          super(format)
          @address_type = address_type if Person::ADDRESS_TYPES.include?(address_type.to_s)
        end

        def address(contactable, name)
          if contactable.is_a?(Person) && @address_type
            proxy = AddressProxy.new(contactable, @address_type)
            super(proxy, proxy.full_name)
          else
            super(contactable, name)
          end
        end

        def print_company?(contactable, name)
          contactable.company_name? && contactable.company_name != name
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

          def company?
            @person.company?
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
