# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2015::CostAccounting
  module Report
    class Deckungsbeitrag4 < Deckungsbeitrag
      def beratung
        table.value_of("deckungsbeitrag3", "beratung").to_d +
          table.value_of("beitraege_iv", "beratung").to_d
      end

      def treffpunkte
        table.value_of("deckungsbeitrag3", "treffpunkte").to_d +
          table.value_of("beitraege_iv", "treffpunkte").to_d
      end

      def blockkurse
        table.value_of("deckungsbeitrag3", "blockkurse").to_d +
          table.value_of("beitraege_iv", "blockkurse").to_d
      end

      def tageskurse
        table.value_of("deckungsbeitrag3", "tageskurse").to_d +
          table.value_of("beitraege_iv", "tageskurse").to_d
      end

      def jahreskurse
        table.value_of("deckungsbeitrag3", "jahreskurse").to_d +
          table.value_of("beitraege_iv", "jahreskurse").to_d
      end

      def lufeb
        table.value_of("deckungsbeitrag3", "lufeb").to_d +
          table.value_of("beitraege_iv", "lufeb").to_d
      end

      def mittelbeschaffung
        table.value_of("deckungsbeitrag3", "mittelbeschaffung").to_d
      end
    end
  end
end
