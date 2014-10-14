# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# Normalize the four additional addresses of a person.
#
# # if the _same_as_main flag is set, copy all fields from main.
# # if all fields are empty, set the _same_as_main flag and copy all fields from main.
# # if all fields are equal to main, set the _same_as_main flag
class Person::AddressNormalizer

  attr_reader :person

  def initialize(person)
    @person = person
  end

  def run
    # when seeding the root user, insieme migrations are not loaded yet, thus we check respond_to.
    return unless person.respond_to?(:billing_general_same_as_main)

    Person::ADDRESS_TYPES.each do |type|
      normalize_fields(type)
    end
  end

  private

  def normalize_fields(type)
    if same_as_main?(type)
      copy_fields_from_main(type)
    elsif all_fields_empty?(type)
      set_same_as_main(type)
      copy_fields_from_main(type)
    elsif all_fields_equal_to_main?(type)
      set_same_as_main(type)
    end
  end

  def same_as_main?(type)
    person.send("#{type}_same_as_main?")
  end

  # rubocop:disable Style/AccessorMethodName
  def set_same_as_main(type)
    person.send("#{type}_same_as_main=", true)
  end
  # rubocop:enable Style/AccessorMethodName

  def copy_fields_from_main(type)
    fields(type).each do |typed_field, field|
      person.send("#{typed_field}=", person.send(field))
    end
  end

  def all_fields_empty?(type)
    fields(type).all? { |typed_field, _| person.send(typed_field).blank?  }
  end

  def all_fields_equal_to_main?(type)
    fields(type).all? do |typed_field, field|
      person.send(typed_field) == person.send(field)
    end
  end

  def fields(type)
    Person::ADDRESS_FIELDS.map { |field| [[type, field].join('_'), field] }
  end

end
