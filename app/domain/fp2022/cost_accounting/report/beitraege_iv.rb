# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2022::CostAccounting
  module Report
    class BeitraegeIv < Base
      self.kontengruppe = "330"

      self.aufwand = false

      delegate_editable_fields %w[aufwand_ertrag_fibu
        aufteilung_kontengruppen
        abgrenzung_fibu

        beratung
        medien_und_publikationen
        treffpunkte
        blockkurse
        tageskurse
        jahreskurse
        lufeb]
    end
  end
end
