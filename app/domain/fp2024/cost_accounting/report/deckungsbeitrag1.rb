# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2024::CostAccounting
  module Report
    class Deckungsbeitrag1 < Deckungsbeitrag
      def beratung
        table.value_of("leistungsertrag", "beratung").to_d -
          table.value_of("total_aufwand", "beratung").to_d
      end

      def medien_und_publikationen
        table.value_of("leistungsertrag", "medien_und_publikationen").to_d -
          table.value_of("total_aufwand", "medien_und_publikationen").to_d
      end

      def treffpunkte
        table.value_of("leistungsertrag", "treffpunkte").to_d -
          table.value_of("total_aufwand", "treffpunkte").to_d
      end

      def blockkurse
        table.value_of("leistungsertrag", "blockkurse").to_d -
          table.value_of("total_aufwand", "blockkurse").to_d
      end

      def tageskurse
        table.value_of("leistungsertrag", "tageskurse").to_d -
          table.value_of("total_aufwand", "tageskurse").to_d
      end

      def jahreskurse
        table.value_of("leistungsertrag", "jahreskurse").to_d -
          table.value_of("total_aufwand", "jahreskurse").to_d
      end

      def lufeb
        table.value_of("leistungsertrag", "lufeb").to_d -
          table.value_of("total_aufwand", "lufeb").to_d
      end

      def mittelbeschaffung
        table.value_of("leistungsertrag", "mittelbeschaffung").to_d -
          table.value_of("total_aufwand", "mittelbeschaffung").to_d
      end
    end
  end
end
