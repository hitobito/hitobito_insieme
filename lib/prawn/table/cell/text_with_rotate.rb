# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'prawn/table/cell/text'

module Prawn
  class Table
    class Cell
      module TextWithRotate

        extend ActiveSupport::Concern

        included do
          alias_method_chain :text_box, :rotate
        end

        def text_box_with_rotate(extra_options={})
          if @text_options[:rotate] == 90
            extra_options[:width] = height
          end
          text_box_without_rotate(extra_options)
        end

      end
    end
  end
end

Prawn::Table::Cell::Text.send(:include, Prawn::Table::Cell::TextWithRotate)
