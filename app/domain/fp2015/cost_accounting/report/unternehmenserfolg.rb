# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2015::CostAccounting
  module Report
    class Unternehmenserfolg < Base
      self.kind = :unternehmenserfolg

      def aufwand_ertrag_ko_re
        nil
      end

      def total
        @total ||= table.value_of('total_ertraege', 'aufwand_ertrag_fibu').to_d - \
                   table.value_of('total_aufwand', 'aufwand_ertrag_fibu').to_d
      end

      def kontrolle
        nil
      end
    end
  end
end
