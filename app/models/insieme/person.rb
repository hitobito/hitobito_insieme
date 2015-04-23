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
    before_save :normalize_disabled_person_reference

    validates :canton, inclusion: { in: Cantons.short_name_strings, allow_blank: true }
    validates :number, presence: true, uniqueness: true
    validates :disabled_person_birthday, timeliness: { type: :date, allow_blank: true }

    validate :assert_address_types_zip_is_valid_swiss_post_code
  end

  def reference_person
    @reference_person ||= reference_person_number &&
      Person.find_by(number: reference_person_number)
  end

  def grouped_active_membership_roles
    if @grouped_active_membership_roles.nil?
      active_memberships = roles.includes(:group).
                                 joins(:group).
                                 where(groups: { type: ::Group::Aktivmitglieder })
      @grouped_active_membership_roles = Hash.new { |h, k| h[k] = [] }
      active_memberships.each do |role|
        @grouped_active_membership_roles[role.group] << role
      end
    end
    @grouped_active_membership_roles
  end

  def canton_label
    Cantons.full_name(canton)
  end

  private

  def assert_address_types_zip_is_valid_swiss_post_code
    ADDRESS_TYPES.each do |address_type|
      zip_code = send("#{address_type}_zip_code").to_s.strip
      country =  send("#{address_type}_country").to_s.strip.downcase

      if swiss_country?(country) && zip_code.present? && !zip_code.match(/^\d{4}$/)
        errors.add("#{address_type}_zip_code")
      end
    end
  end

  def swiss_country?(country)
    ['', *Settings.address.switzerland_variations].include?(country)
  end

  def normalize_i18n_keys
    canton.downcase! if canton?
    language.downcase! if language?
    correspondence_language.downcase! if correspondence_language?
  end

  def normalize_addresses
    Person::AddressNormalizer.new(self).run
  end

  def normalize_disabled_person_reference
    # when seeding the root user, insieme migrations are not loaded yet, thus we check respond_to.
    return unless respond_to?(:disabled_person_reference)

    unless disabled_person_reference
      self.disabled_person_first_name = nil
      self.disabled_person_last_name = nil
      self.disabled_person_address = nil
      self.disabled_person_zip_code = nil
      self.disabled_person_town = nil
      self.disabled_person_birthday = nil
    end
  end

end
