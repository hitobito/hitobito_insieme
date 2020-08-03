# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020::CostAccounting
  module Report
    class Vollkosten < Subtotal

      self.summed_reports = %w(lohnaufwand
                               sozialversicherungsaufwand
                               uebriger_personalaufwand
                               honorare
                               raumaufwand
                               uebriger_sachaufwand
                               abschreibungen

                               umlage_personal
                               umlage_raeumlichkeiten
                               umlage_verwaltung)

      self.summed_fields = %w(beratung
                              treffpunkte
                              blockkurse
                              tageskurse
                              jahreskurse
                              lufeb
                              mittelbeschaffung
                              medien_und_publikationen)

      define_summed_field_methods

      def aufwand_ertrag_ko_re
        nil
      end

    end
  end
end
