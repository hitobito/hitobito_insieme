# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CostAccounting
  module Report
    class UebrigerSachaufwand < Base

      self.kontengruppe = '40-43/61-67'

      self.used_fields += %w(verwaltung)

      delegate_editable_fields %w(aufwand_ertrag_fibu
                                  aufteilung_kontengruppen
                                  abgrenzung_fibu
                                  abgrenzung_dachorganisation

                                  verwaltung
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
