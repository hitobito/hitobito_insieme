# frozen_string_literal: true

#  Copyright (c) 2012-2014, 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020::CostAccounting
  module Report
    class Vollkosten < Subtotal

      self.summed_reports = %w(
        total_aufwand
        total_umlagen
      )

      self.summed_fields = %w(
        beratung
        treffpunkte
        blockkurse
        tageskurse
        jahreskurse
        lufeb
        medien_und_publikationen
      )

      self.total_includes_gemeinkostentraeger = false

      define_summed_field_methods

      def aufwand_ertrag_ko_re
        nil
      end

    end
  end
end
