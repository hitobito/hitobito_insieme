# frozen_string_literal: true

#  Copyright (c) 2012-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AddAddressLabelsToPeople < ActiveRecord::Migration[6.1]
  ADDRESS_TYPES = %w(correspondence_general
                     billing_general
                     correspondence_course
                     billing_course).freeze
  def change
    ADDRESS_TYPES.each do |concern|
      add_column :people, "#{concern}_label", :string, limit: 20 # was 255, the varchar-default
    end
  end
end
