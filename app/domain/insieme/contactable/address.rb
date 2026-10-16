# frozen_string_literal: true

#  Copyright (c) 2022-2026, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Contactable::Address
  private

  # NOTE: according to existing specs, this wagon relies only on company_name and ignores the
  # company flag
  def print_company?(name)
    company_name? && company_name != name
  end
end
