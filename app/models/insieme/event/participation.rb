# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Event
    module Participation
      extend ActiveSupport::Concern

      included do
        accepts_nested_attributes_for :person
      end

      def self.accepted_person_attributes
        attributes = %w(canton birthday address zip_code town country)
        %w(correspondence_course billing_course ).each do |prefix|
          %w(full_name company_name company address zip_code town country).each do |field|
            attributes << "#{prefix}_#{field}"
          end
        end
        attributes
      end
    end
  end
end
