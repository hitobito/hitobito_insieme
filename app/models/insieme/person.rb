# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Person
  extend ActiveSupport::Concern

  included do
    Person::PUBLIC_ATTRS << :insieme_full_name

    %w( correspondence_general
        billing_general
        correspondence_course
        billing_course ).each do |prefix|
      %w( full_name company_name company address zip_code town country).each do |field|
        Person::PUBLIC_ATTRS << :"#{prefix}_#{field}"
      end
    end

    before_save :add_insieme_full_name
  end

  def canton_value
    value_from_i18n(:canton)
  end

  def language_value
    value_from_i18n(:language)
  end

  def correspondence_language_value
    value_from_i18n(:correspondence_language)
  end

  private

  def value_from_i18n(key)
    value = send(key)

    if value.present?
      I18n.t("activerecord.attributes.person.#{key.to_s.pluralize}.#{value}")
    end
  end

  def add_insieme_full_name
    # when seeding the root user, insieme migrations are not loaded yet, thus we check respond_to.
    if respond_to?(:insieme_full_name) && insieme_full_name.blank?
      self.insieme_full_name = "#{first_name} #{last_name}"
    end
  end
end
