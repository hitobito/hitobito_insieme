# frozen_string_literal: true

#  Copyright (c) 2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Person::Address
  def for_invoice
    (billing_general_person_and_company_name + billing_general_address).compact.join("\n")
  end

  private

  def billing_general_person_and_company_name
    if @person.billing_general_company?
      [
        @person.billing_general_company_name.to_s.squish,
        @person.billing_general_full_name.to_s.squish
      ].reject(&:blank?)
    else
      [@person.billing_general_full_name.to_s.squish]
    end
  end

  def billing_general_address
    [@person.billing_general_address.to_s.strip,
     [@person.billing_general_zip_code, @person.billing_general_town].
       compact.
       join(' ').
       squish,
     country]
  end
end
