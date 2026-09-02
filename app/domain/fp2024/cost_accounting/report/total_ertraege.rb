# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2024::CostAccounting
  module Report
    class TotalErtraege < Subtotal
      self.used_fields += %w[verwaltung]

      self.summed_reports = %w[leistungsertrag
        beitraege_iv
        sonstige_beitraege
        direkte_spenden
        indirekte_spenden
        direkte_spenden_ausserhalb]

      self.summed_fields = %w[aufwand_ertrag_fibu
        abgrenzung_fibu

        beratung
        medien_und_publikationen
        treffpunkte
        blockkurse
        tageskurse
        jahreskurse
        lufeb
        mittelbeschaffung]

      define_summed_field_methods
    end
  end
end
