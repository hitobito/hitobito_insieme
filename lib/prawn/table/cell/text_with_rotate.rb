#  Copyright (c) 2014-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'prawn/table/cell/text'

module Prawn
  class Table
    class Cell
      module TextWithRotate

        def text_box(extra_options={})
          if @text_options[:rotate] == 90
            extra_options[:width] = height
          end
          super(extra_options)
        end

      end
    end
  end
end

Prawn::Table::Cell::Text.send(:prepend, Prawn::Table::Cell::TextWithRotate)
