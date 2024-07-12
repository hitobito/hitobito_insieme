# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Export::Tabular::People
  module HouseholdRow
    def name
      with_combined_first_names.collect do |last_name, combined_first_name|
        without_blanks([combined_first_name, last_name]).join(" ")
      end.join(", ")
    end
  end
end
