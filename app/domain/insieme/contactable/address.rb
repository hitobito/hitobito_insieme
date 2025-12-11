# frozen_string_literal: true

#  Copyright (c) 2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Contactable::Address
  def invoice_recipient_address_attributes # rubocop:disable Metrics/AbcSize
    return super unless contactable.is_a?(Person)

    with_invoice_addressable do
      {
        recipient_address_care_of: "",
        recipient_company_name: billing_general_company? ?
          billing_general_company_name.to_s.squish : nil,
        recipient_name: billing_general_full_name.to_s.squish,
        recipient_street: billing_general_street.to_s.squish,
        recipient_housenumber: billing_general_housenumber.to_s.squish,
        recipient_postbox: "",
        recipient_zip_code: billing_general_zip_code,
        recipient_town: billing_general_town,
        recipient_country: billing_general_country || default_country
      }
    end
  end

  private

  delegate :billing_general_company?, :billing_general_company_name, :billing_general_full_name,
    :billing_general_address, :billing_general_zip_code, :billing_general_town,
    :billing_general_country, to: :contactable

  # NOTE: according to existing specs, this wagon relies only on company_name and ignores the
  # company flag
  def print_company?(name)
    company_name? && company_name != name
  end

  def billing_general_person_and_company_name
    if billing_general_company?
      [
        billing_general_company_name.to_s.squish,
        billing_general_full_name.to_s.squish
      ].compact_blank
    else
      [billing_general_full_name.to_s.squish]
    end
  end

  # TODO this is a pretty dumb implementation for a very complex task
  # see https://github.com/hitobito/hitobito_insieme/issues/195
  def billing_general_street
    parts = billing_general_address.split(" ")
    (parts.length > 1) ? parts[0..-2].join(" ") : parts[0]
  end

  # TODO this is a pretty dumb implementation for a very complex task
  # see https://github.com/hitobito/hitobito_insieme/issues/195
  def billing_general_housenumber
    parts = billing_general_address.split(" ")
    (parts.length > 1) ? parts[-1] : nil
  end
end
