# frozen_string_literal: true

#  Copyright (c) 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2015::CostAccounting
  module Report
    class Separator < Base
      self.kind = :separator

      def aufwand_ertrag_ko_re
        nil
      end

      def kontrolle
        nil
      end

      def total
        nil
      end
    end
  end
end
