# encoding: utf-8

#  Copyright (c) 2014 insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Import
    module PersonDoubletteFinder
      extend ActiveSupport::Concern

      included do
        alias_method_chain :assign_blank_attrs, :number
        alias_method_chain :duplicates, :number
      end

      def assign_blank_attrs_with_number(person)
        if person.errors.empty?
          assign_blank_attrs_without_number(person)
        end
      end

      private

      def duplicates_with_number
        if attrs[:number].present?
          ::Person.where(number: attrs[:number]).to_a.presence ||
          check_duplicate_with_different_number
        else
          duplicates_without_number
        end
      end

      def check_duplicate_with_different_number
        duplicates = duplicates_without_number
        if duplicates.present?
          person = duplicates.first
          if person.number?
            person.errors.add(:base,
                              translate(:duplicate_with_different_number,
                                        number: person.number))
          end
        else
          attrs[:manual_number] = true
        end
        duplicates
      end
    end
  end
end
