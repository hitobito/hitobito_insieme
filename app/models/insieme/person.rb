# frozen_string_literal: true

#  Copyright (c) 2012-2024, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Person
  extend ActiveSupport::Concern

  LANGUAGES = %w[de fr it en another].freeze
  CORRESPONDENCE_LANGUAGES = %w[de fr].freeze

  included do
    attr_accessor :newly_registered

    Person::PUBLIC_ATTRS << :number << :salutation << :correspondence_language

    Person::SEARCHABLE_ATTRS << :salutation

    i18n_enum :language, LANGUAGES
    i18n_enum :correspondence_language, CORRESPONDENCE_LANGUAGES

    before_validation :normalize_i18n_keys
    before_save :normalize_disabled_person_reference

    validates :number, presence: true, uniqueness: true
    validates :disabled_person_birthday,
      timeliness: {type: :date, allow_blank: true, before: Date.new(9999, 12, 31)}

    validate :assert_full_name_or_company_name

    validates :street, presence: true, unless: :newly_registered
    validates :zip_code, presence: true, unless: :newly_registered
    validates :town, presence: true, unless: :newly_registered
    validates :country, presence: true, unless: :newly_registered

    validates :correspondence_language, presence: true, unless: :newly_registered
    validates :language, presence: true, unless: :newly_registered
  end

  def reference_person
    @reference_person ||= reference_person_number &&
      Person.find_by(number: reference_person_number)
  end

  def grouped_active_membership_roles
    if @grouped_active_membership_roles.nil?
      active_memberships = roles.includes(:group)
        .joins(:group)
        .where(groups: {type: ::Group::Aktivmitglieder.sti_name})
      @grouped_active_membership_roles = Hash.new { |h, k| h[k] = [] }
      active_memberships.each do |role|
        @grouped_active_membership_roles[role.group] << role
      end
    end
    @grouped_active_membership_roles
  end

  private

  def assert_full_name_or_company_name
    if company?
      errors.add(:company_name, :blank) if company_name.blank?
    else
      errors.add(:first_name, :blank) if first_name.blank?
      errors.add(:last_name, :blank) if last_name.blank?
    end
  end

  def normalize_i18n_keys
    language.downcase! if language?
    correspondence_language.downcase! if correspondence_language?
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
