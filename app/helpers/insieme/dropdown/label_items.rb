# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Dropdown
    module LabelItems
      extend ActiveSupport::Concern

      included do
        alias_method_chain :add_last_used_format_item, :different_addresses
        alias_method_chain :add_label_format_items, :different_addresses
      end

      private

      def add_last_used_format_item_with_different_addresses(_parent)
        # feature not provided
      end

      def add_label_format_items_with_different_addresses(parent)
        LabelFormat.list.for_person(user).each do |label_format|
          format_item = export_label_item(label_format.id, :main, label_format.to_s)
          parent.sub_items << format_item

          ([:main] + Person::ADDRESS_TYPES).each do |type|
            format_item.sub_items << export_label_item(label_format.id, type)
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

    end
  end
end
