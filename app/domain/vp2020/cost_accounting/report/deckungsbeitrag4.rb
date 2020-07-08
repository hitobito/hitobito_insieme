# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020::CostAccounting
  module Report
    class Deckungsbeitrag4 < CostAccounting::Report::Deckungsbeitrag
      def beratung
        table.value_of('leistungsertrag', 'beratung').to_d - \
        table.value_of('total_aufwand', 'beratung').to_d - \
        table.value_of('total_umlagen', 'beratung').to_d + \
        table.value_of('direkte_spenden', 'beratung').to_d + \
        table.value_of('indirekte_spenden', 'beratung').to_d + \
        table.value_of('sonstige_beitraege', 'beratung').to_d + \
        table.value_of('beitraege_iv', 'beratung').to_d
      end

      def treffpunkte
        table.value_of('leistungsertrag', 'treffpunkte').to_d - \
        table.value_of('total_aufwand', 'treffpunkte').to_d - \
        table.value_of('total_umlagen', 'treffpunkte').to_d + \
        table.value_of('direkte_spenden', 'treffpunkte').to_d + \
        table.value_of('indirekte_spenden', 'treffpunkte').to_d + \
        table.value_of('sonstige_beitraege', 'treffpunkte').to_d + \
        table.value_of('beitraege_iv', 'treffpunkte').to_d
      end

      def blockkurse
        table.value_of('leistungsertrag', 'blockkurse').to_d - \
        table.value_of('total_aufwand', 'blockkurse').to_d - \
        table.value_of('total_umlagen', 'blockkurse').to_d + \
        table.value_of('direkte_spenden', 'blockkurse').to_d + \
        table.value_of('indirekte_spenden', 'blockkurse').to_d + \
        table.value_of('sonstige_beitraege', 'blockkurse').to_d + \
        table.value_of('beitraege_iv', 'blockkurse').to_d
      end

      def tageskurse
        table.value_of('leistungsertrag', 'tageskurse').to_d - \
        table.value_of('total_aufwand', 'tageskurse').to_d - \
        table.value_of('total_umlagen', 'tageskurse').to_d + \
        table.value_of('direkte_spenden', 'tageskurse').to_d + \
        table.value_of('indirekte_spenden', 'tageskurse').to_d + \
        table.value_of('sonstige_beitraege', 'tageskurse').to_d + \
        table.value_of('beitraege_iv', 'tageskurse').to_d
      end

      def jahreskurse
        table.value_of('leistungsertrag', 'jahreskurse').to_d - \
        table.value_of('total_aufwand', 'jahreskurse').to_d - \
        table.value_of('total_umlagen', 'jahreskurse').to_d + \
        table.value_of('direkte_spenden', 'jahreskurse').to_d + \
        table.value_of('indirekte_spenden', 'jahreskurse').to_d + \
        table.value_of('sonstige_beitraege', 'jahreskurse').to_d + \
        table.value_of('beitraege_iv', 'jahreskurse').to_d
      end

      def lufeb
        table.value_of('leistungsertrag', 'lufeb').to_d - \
        table.value_of('total_aufwand', 'lufeb').to_d - \
        table.value_of('total_umlagen', 'lufeb').to_d + \
        table.value_of('direkte_spenden', 'lufeb').to_d + \
        table.value_of('indirekte_spenden', 'lufeb').to_d + \
        table.value_of('sonstige_beitraege', 'lufeb').to_d + \
        table.value_of('beitraege_iv', 'lufeb').to_d
      end

      def mittelbeschaffung
        table.value_of('leistungsertrag', 'mittelbeschaffung').to_d - \
        table.value_of('total_aufwand', 'mittelbeschaffung').to_d - \
        table.value_of('total_umlagen', 'mittelbeschaffung').to_d + \
        table.value_of('direkte_spenden', 'mittelbeschaffung').to_d + \
        table.value_of('indirekte_spenden', 'mittelbeschaffung').to_d + \
        table.value_of('sonstige_beitraege', 'mittelbeschaffung').to_d
      end
    end
  end
end
