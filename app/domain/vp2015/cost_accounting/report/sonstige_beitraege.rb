# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2015::CostAccounting
  module Report
    class SonstigeBeitraege < Base

      self.kontengruppe = '331'

      self.aufwand = false

      delegate_editable_fields %w(aufwand_ertrag_fibu
                                  aufteilung_kontengruppen
                                  abgrenzung_fibu
                                  abgrenzung_dachorganisation

                                  beratung
                                  treffpunkte
                                  blockkurse
                                  tageskurse
                                  jahreskurse
                                  lufeb
                                  mittelbeschaffung)

    end
  end
end
