# frozen_string_literal: true

#  Copyright (c) 2012-2014, 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020::CostAccounting
  module Report
    # Gemeinkosten
    class TotalUmlagen < Subtotal

      self.total_includes_gemeinkostentraeger = true

      self.summed_reports = %w(
        umlage_personal
        umlage_raeumlichkeiten
        umlage_verwaltung
        umlage_mittelbeschaffung

        total_personalaufwand
        raumaufwand
        uebriger_sachaufwand
        abschreibungen
      )

      self.summed_fields = %w(
        beratung
        medien_und_publikationen
        treffpunkte
        blockkurse
        tageskurse
        jahreskurse
        lufeb
        mittelbeschaffung
        verwaltung
        raeumlichkeiten
      )

      define_summed_field_methods

      def aufwand_ertrag_ko_re
        nil
      end

    end
  end
end
