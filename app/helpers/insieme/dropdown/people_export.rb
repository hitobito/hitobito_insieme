# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Dropdown
    module PeopleExport
      extend ActiveSupport::Concern

      included do
        alias_method_chain :add_last_used_format_item, :different_addresses
        alias_method_chain :add_label_format_items, :different_addresses
        alias_method_chain :add_condensed_labels_option_items, :not
      end

      private

      def add_last_used_format_item_with_different_addresses(_parent)
        # feature not provided
      end

      def add_label_format_items_with_different_addresses(parent)
        LabelFormat.all_as_hash.each do |id, label|
          format_item = export_label_item(id, :main, label)
          parent.sub_items << format_item

          ([:main] + Person::ADDRESS_TYPES).each do |type|
            format_item.sub_items << export_label_item(id, type)
          end
        end
      end

      def export_label_item(format_id, type, label = nil)
        ::Dropdown::Item.new(label || I18n.t("contactable.address_fields_insieme.#{type}"),
                             params.merge(format: :pdf,
                                          label_format_id: format_id,
                                          address_type: type),
                             target: :new)
      end

      def add_condensed_labels_option_items_with_not(label_item)
        # do not add this option for insieme, as it does not (yet) work with mutliple address types
      end

    end
  end
end
