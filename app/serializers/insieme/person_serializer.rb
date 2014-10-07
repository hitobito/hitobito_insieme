# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::PersonSerializer
  extend ActiveSupport::Concern

  included do
    extension(:details) do |_|
      map_properties :salutation,
                     :canton,
                     :language,
                     :correspondence_language,
                     :number

      property :full_name, item.insieme_full_name

      ::Person::ADDRESS_TYPES.each do |prefix|
        ::Person::ADDRESS_FIELDS.each do |field|
          map_properties :"#{prefix}_#{field}"
        end
      end
    end
  end

end
