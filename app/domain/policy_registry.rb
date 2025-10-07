# frozen_string_literal: true

#  Copyright (c) 2020-2021, Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# Selects the applicable FSIO 2024–2028 policy version for a given reporting year.
#
# The PolicyRegistry centralizes which policy class governs a specific year
# within a contractual period. This allows year-by-year behavioral changes
# (e.g. calculation rules, inclusion logic) without creating a new feature-period
# namespace.
#
# Example:
#   policy = PolicyRegistry.for(year: 2025)
#   policy.include_grundlagen_hours? # => true / false
#
# Each time business rules change, a new policy version (e.g. V12) is added and
# mapped here with the corresponding year range.
class PolicyRegistry
  def self.for(year:)
    case year.to_i
    when 2024
      Policies::Fsio2428::V10.new
    when 2025..Float::INFINITY
      Policies::Fsio2428::V11.new
    else
      Policies::Fsio2428::V10.new
    end
  end
end
