# frozen_string_literal: true
#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CostAccounting
  module Report
    class Deckungsbeitrag3 < Deckungsbeitrag
      def beratung
        table.value_of('deckungsbeitrag2', 'beratung').to_d + \
        table.value_of('sonstige_beitraege', 'beratung').to_d
      end

      def treffpunkte
        table.value_of('deckungsbeitrag2', 'treffpunkte').to_d + \
        table.value_of('sonstige_beitraege', 'treffpunkte').to_d
      end

      def blockkurse
        table.value_of('deckungsbeitrag2', 'blockkurse').to_d + \
        table.value_of('sonstige_beitraege', 'blockkurse').to_d
      end

      def tageskurse
        table.value_of('deckungsbeitrag2', 'tageskurse').to_d + \
        table.value_of('sonstige_beitraege', 'tageskurse').to_d
      end

      def jahreskurse
        table.value_of('deckungsbeitrag2', 'jahreskurse').to_d + \
        table.value_of('sonstige_beitraege', 'jahreskurse').to_d
      end

      def lufeb
        table.value_of('deckungsbeitrag2', 'lufeb').to_d + \
        table.value_of('sonstige_beitraege', 'lufeb').to_d
      end

      def mittelbeschaffung
        table.value_of('deckungsbeitrag2', 'mittelbeschaffung').to_d + \
        table.value_of('sonstige_beitraege', 'mittelbeschaffung').to_d
      end
    end
  end
end
