# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2015::CostAccounting
  module Report
    class Raumaufwand < CourseRelated
      self.kontengruppe = "600"

      self.used_fields += %w[raeumlichkeiten]

      delegate_editable_fields %w[aufwand_ertrag_fibu
        aufteilung_kontengruppen
        abgrenzung_fibu
        abgrenzung_dachorganisation

        raeumlichkeiten
        beratung
        treffpunkte
        lufeb
        mittelbeschaffung]
    end
  end
end
