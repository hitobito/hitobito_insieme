# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2024::CostAccounting
  module Report
    class Deckungsbeitrag < Base
      self.kind = :deckungsbeitrag

      def aufteilung_kontengruppen
        nil
      end

      def aufwand_ertrag_fibu
        nil
      end

      def abgrenzung_fibu
        nil
      end

      def abgrenzung_dachorganisation
        nil
      end

      def aufwand_ertrag_ko_re
        nil
      end

      def personal
        nil
      end

      def raeumlichkeiten
        nil
      end

      def verwaltung
        nil
      end

      def kontrolle
        nil
      end
    end
  end
end
