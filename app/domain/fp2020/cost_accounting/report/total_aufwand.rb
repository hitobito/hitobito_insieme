# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2020::CostAccounting
  module Report
    # Total Aufwand/Kosten
    class TotalAufwand < Subtotal
      self.total_includes_gemeinkostentraeger = false

      self.used_fields += %w[
        verwaltung
      ]

      self.summed_reports = %w[
        total_personalaufwand
        raumaufwand
        uebriger_sachaufwand
        abschreibungen
      ]

      self.summed_fields = %w[
        aufwand_ertrag_fibu
        abgrenzung_fibu

        beratung
        medien_und_publikationen
        treffpunkte
        blockkurse
        tageskurse
        jahreskurse
        lufeb
      ]

      self.total_includes_gemeinkostentraeger = false

      define_summed_field_methods

      def total
        super + table.value_of("total_umlagen", "gemeinkostentraeger").to_d
      end
    end
  end
end
