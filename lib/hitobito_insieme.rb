# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "wagons"
# require 'your_wagon_dependencies'
require "prawn/table/cell/text_with_rotate"
require "hitobito_insieme/wagon"

module HitobitoInsieme
end

class NilClass
  def to_d
    BigDecimal("0")
  end
end
