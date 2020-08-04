# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020::CostAccounting
  module Report
    class IndirekteSpenden < Base

      self.kontengruppe = '3320/680-685/74/333/335/910'

      self.aufwand = false

      delegate_editable_fields %w(aufwand_ertrag_fibu
                                  aufteilung_kontengruppen

                                  beratung
                                  medien_und_publikationen
                                  treffpunkte
                                  blockkurse
                                  tageskurse
                                  jahreskurse
                                  lufeb)

      def abgrenzung_fibu
        abgrenzung_factor && (abgrenzung_factor * aufwand_ertrag_fibu.to_d)
      end

      def abgrenzung_factor
        @abgrenzung_factor ||= table.value_of('total_aufwand', 'aufwand_ertrag_fibu').nonzero? && \
                               (1 - table.value_of('vollkosten', 'total').to_d / \
                                table.value_of('total_aufwand', 'aufwand_ertrag_fibu').to_d)
      end

    end
  end
end
