# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Person
  extend ActiveSupport::Concern

  included do
    LANGUAGES = %w(de fr it en other)
    CORRESPONDENCE_LANGUAGES = %w(de fr)

    ADDRESS_TYPES = %w(correspondence_general
                       billing_general
                       correspondence_course
                       billing_course)

    ADDRESS_FIELDS = %w(salutation first_name last_name company_name company
                        address zip_code town country)

    Person::PUBLIC_ATTRS << :number << :salutation << :correspondence_language

    ADDRESS_TYPES.each do |prefix|
      ADDRESS_FIELDS.each do |field|
        Person::PUBLIC_ATTRS << :"#{prefix}_#{field}"
      end

      i18n_boolean_setter "#{prefix}_company"
    end

    i18n_enum :language, LANGUAGES
    i18n_enum :correspondence_language, CORRESPONDENCE_LANGUAGES

    before_validation :normalize_i18n_keys
    before_save :normalize_addresses

    validates :canton, inclusion: { in: Cantons.short_name_strings, allow_blank: true }
    validates :number, presence: true, uniqueness: true
  end

  def canton_label
    Cantons.full_name(canton)
  end

  private

  def normalize_i18n_keys
    canton.downcase! if canton?
    language.downcase! if language?
    correspondence_language.downcase! if correspondence_language?
  end

  def normalize_addresses
    Person::AddressNormalizer.new(self).run
  end

end
