# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020::CostAccounting
  module Report
    class UebrigerSachaufwand < CourseRelated

      self.kontengruppe = '40-43/61-67'

      self.used_fields += %w(verwaltung)

      delegate_editable_fields %w(aufwand_ertrag_fibu
                                  aufteilung_kontengruppen
                                  abgrenzung_fibu

                                  verwaltung
                                  beratung
                                  medien_und_publikationen
                                  lufeb
                                  mittelbeschaffung)

    end
  end
end
