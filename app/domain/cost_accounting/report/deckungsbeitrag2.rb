# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CostAccounting
  module Report
    class Deckungsbeitrag2 < Deckungsbeitrag
      def beratung
        table.value_of('deckungsbeitrag1', 'beratung').to_d - \
        table.value_of('total_umlagen', 'beratung').to_d + \
        table.value_of('direkte_spenden', 'beratung').to_d + \
        table.value_of('indirekte_spenden', 'beratung').to_d
      end

      def treffpunkte
        table.value_of('deckungsbeitrag1', 'treffpunkte').to_d - \
        table.value_of('total_umlagen', 'treffpunkte').to_d + \
        table.value_of('direkte_spenden', 'treffpunkte').to_d + \
        table.value_of('indirekte_spenden', 'treffpunkte').to_d
      end

      def blockkurse
        table.value_of('deckungsbeitrag1', 'blockkurse').to_d - \
        table.value_of('total_umlagen', 'blockkurse').to_d + \
        table.value_of('direkte_spenden', 'blockkurse').to_d + \
        table.value_of('indirekte_spenden', 'blockkurse').to_d
      end

      def tageskurse
        table.value_of('deckungsbeitrag1', 'tageskurse').to_d - \
        table.value_of('total_umlagen', 'tageskurse').to_d + \
        table.value_of('direkte_spenden', 'tageskurse').to_d + \
        table.value_of('indirekte_spenden', 'tageskurse').to_d
      end

      def jahreskurse
        table.value_of('deckungsbeitrag1', 'jahreskurse').to_d - \
        table.value_of('total_umlagen', 'jahreskurse').to_d + \
        table.value_of('direkte_spenden', 'jahreskurse').to_d + \
        table.value_of('indirekte_spenden', 'jahreskurse').to_d
      end

      def lufeb
        table.value_of('deckungsbeitrag1', 'lufeb').to_d - \
        table.value_of('total_umlagen', 'lufeb').to_d + \
        table.value_of('direkte_spenden', 'lufeb').to_d + \
        table.value_of('indirekte_spenden', 'lufeb').to_d
      end

      def mittelbeschaffung
        table.value_of('deckungsbeitrag1', 'mittelbeschaffung').to_d - \
        table.value_of('total_umlagen', 'mittelbeschaffung').to_d + \
        table.value_of('direkte_spenden', 'mittelbeschaffung').to_d + \
        table.value_of('indirekte_spenden', 'mittelbeschaffung').to_d
      end
    end
  end
end
