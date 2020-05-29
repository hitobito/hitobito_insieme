# frozen_string_literal: true

#  Copyright (c) 2014-2020, insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Import
    module PersonDoubletteFinder
      private

      def duplicates(attrs)
        if attrs[:number].present?
          ::Person.where(number: attrs[:number]).to_a.presence ||
          check_duplicate_with_different_number(attrs, super)
        else
          super(attrs)
        end
      end

      def check_duplicate_with_different_number(attrs, duplicates)
        if duplicates.present?
          person = duplicates.first
          add_duplicate_with_different_number_error(person) if person.number?
        else
          attrs[:manual_number] = true
        end
        duplicates
      end

      def add_duplicate_with_different_number_error(person)
        person.errors.add(:base,
                          translate(:duplicate_with_different_number,
                                    number: person.number))
      end
    end
  end
end
