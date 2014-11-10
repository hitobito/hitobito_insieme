# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Person
  extend ActiveSupport::Concern

  included do
    AUTOMATIC_NUMBER_RANGE = 100_000...1_000_000

    ADDRESS_TYPES = %w(correspondence_general
                       billing_general
                       correspondence_course
                       billing_course)

    ADDRESS_FIELDS = %w(full_name company_name company address zip_code town country)

    Person::PUBLIC_ATTRS << :insieme_full_name << :number << :salutation

    ADDRESS_TYPES.each do |prefix|
      ADDRESS_FIELDS.each do |field|
        Person::PUBLIC_ATTRS << :"#{prefix}_#{field}"
      end

      i18n_boolean_setter "#{prefix}_company"
    end

    before_validation :generate_automatic_number
    before_save :add_insieme_full_name
    before_validation :normalize_i18n_keys
    before_save :normalize_addresses

    validates :number, presence: true, uniqueness: true
    validates :canton, inclusion: { in: Cantons.short_name_strings, allow_blank: true }
    validate :allowed_number_range
  end

  def canton_value
    Cantons.full_name(canton)
  end

  def language_value
    value_from_i18n(:language)
  end

  def correspondence_language_value
    value_from_i18n(:correspondence_language)
  end

  def manual_number=(value)
    @manual_number =
      case value
      when '0', 0, false, nil then false
      else true
      end
  end

  def manual_number
    if @manual_number.nil? && number?
      @manual_number = !number_in_automatic_range?
    end
    @manual_number
  end

  private

  def value_from_i18n(key)
    value = send(key)

    if value.present?
      I18n.t("activerecord.attributes.person.#{key.to_s.pluralize}.#{value.downcase}")
    end
  end

  def add_insieme_full_name
    # when seeding the root user, insieme migrations are not loaded yet, thus we check respond_to.
    if respond_to?(:insieme_full_name) && insieme_full_name.blank?
      self.insieme_full_name = "#{first_name} #{last_name}"
    end
  end

  def allowed_number_range
    if number_in_automatic_range? && manual_number
      add_number_error(:manual_number_in_automatic_range)
    elsif !number_in_automatic_range? && !manual_number
      add_number_error(:automatic_number_in_manual_range)
    end
  end

  def add_number_error(key)
    errors.add(:number,
               key,
               lower: AUTOMATIC_NUMBER_RANGE.first,
               upper: AUTOMATIC_NUMBER_RANGE.last)
  end

  def generate_automatic_number
    unless manual_number
      self.reset_number!
      unless number_in_automatic_range?
        self.number = self.class.next_automatic_number
      end
    end
  end

  def number_in_automatic_range?
    AUTOMATIC_NUMBER_RANGE.cover?(number)
  end

  def normalize_i18n_keys
    canton.downcase! if canton?
    language.downcase! if language?
    correspondence_language.downcase! if correspondence_language?
  end

  def normalize_addresses
    Person::AddressNormalizer.new(self).run
  end

  module ClassMethods
    def next_automatic_number
      p = Person.select(:number).
                 where(number: AUTOMATIC_NUMBER_RANGE).
                 order('number DESC').
                 first
      p ? p.number + 1 : AUTOMATIC_NUMBER_RANGE.first
    end
  end
end
