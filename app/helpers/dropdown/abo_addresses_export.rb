# frozen_string_literal: true
#  Copyright (c) 2014, Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Dropdown
  class AboAddressesExport < Base

    def initialize(template, group)
      super(template, translate(:button), :download)
      @group = group

      init_items
    end

    private

    def init_items
      add_abo_item(:ch, :de)
      add_abo_item(:ch, :fr)
      add_abo_item(:other, :de)
      add_abo_item(:other, :fr)
    end

    def add_abo_item(country, language)
      add_item(translate("#{country}_#{language}"),
               template.abo_addresses_group_path(@group,
                                                 country: country,
                                                 language: language,
                                                 format: :csv))
    end

  end
end
