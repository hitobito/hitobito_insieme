# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020::CostAccounting
  module Report
    class TotalAufwand < Subtotal

      self.used_fields += %w(verwaltung)

      self.summed_reports = %w(lohnaufwand
                               sozialversicherungsaufwand
                               uebriger_personalaufwand
                               honorare
                               raumaufwand
                               uebriger_sachaufwand
                               abschreibungen)

      self.summed_fields = %w(aufwand_ertrag_fibu
                              abgrenzung_fibu
                              abgrenzung_dachorganisation

                              raeumlichkeiten
                              verwaltung
                              beratung
                              medien_und_publikationen
                              treffpunkte
                              blockkurse
                              tageskurse
                              jahreskurse
                              lufeb
                              mittelbeschaffung)

      define_summed_field_methods

    end
  end
end
