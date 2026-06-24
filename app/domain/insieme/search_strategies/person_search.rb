# frozen_string_literal: true

#  Copyright (c) 2026, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::SearchStrategies
  module PersonSearch
    extend ActiveSupport::Concern

    prepended do
      self.searchable_identifiers = searchable_identifiers.merge({
        number: /\A\d+\z/
      })
    end
  end
end
