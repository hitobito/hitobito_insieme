# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Person::AddressUpdater

  attr_reader :person

  def initialize(person)
    @person = person
  end

  def run
    differing_types = Person::ADDRESS_TYPES - equal_or_empty_types

    equal_or_empty_types.each { |type| set_same_as_main(type) }
    differing_types.each { |type|  set_same_as_main(type, false) }
  end

  private

  def equal_or_empty_types
    Person::ADDRESS_TYPES.
      select { |type| fields_equal?(type) || typed_fields_empty?(type) }
  end

  def fields_equal?(type)
    fields(type).all? do |typed_field, field|
      person.send(typed_field) == person.send(field)
    end
  end

  def typed_fields_empty?(type)
    fields(type).
      none? { |typed_field, _| person.send(typed_field).present?  }
  end

  def fields(type, address_fields = Person::ADDRESS_FIELDS)
    address_fields.map { |field| [[type, field].join('_'), field] }
  end

  def set_same_as_main(type, same_as_main = true)
    person.send("#{type}_same_as_main=", same_as_main)

    if same_as_main
      fields(type).each do |typed_field, field|
        person.send("#{typed_field}=", person.send(field))
      end
    end
  end

end
