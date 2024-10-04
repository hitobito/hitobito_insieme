# frozen_string_literal: true

#  Copyright (c) 2014-2020, insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Import
    module PersonDuplicateFinder
      private

      def duplicate_ids_with_first_person(attrs)
        if attrs[:number].present?
          people_ids = ::Person.where(number: attrs[:number]).pluck(:id).presence
          return {people_ids:, first_person: find_first_person(people_ids)} if people_ids
          check_duplicate_with_different_number(attrs, super)
        else
          super
        end
      end

      def check_duplicate_with_different_number(attrs, duplicate_ids_with_first_person)
        duplicate_ids = duplicate_ids_with_first_person[:people_ids]
        first_person = duplicate_ids_with_first_person[:first_person]
        if duplicate_ids.present?
          add_duplicate_with_different_number_error(first_person) if first_person.number?
        else
          attrs[:manual_number] = true
        end
        duplicate_ids_with_first_person
      end

      def add_duplicate_with_different_number_error(person)
        person.errors.add(:base,
          translate(:duplicate_with_different_number,
            number: person.number))
      end
    end
  end
end
