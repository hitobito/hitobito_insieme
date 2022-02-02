# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2021::CostAccounting
  module Report
    class DirekteSpendenAusserhalb < Base

      self.kontengruppe = '3322/920'

      self.aufwand = false

      delegate_editable_fields %w(aufwand_ertrag_fibu
                                  aufteilung_kontengruppen)

      alias_method :abgrenzung_fibu, :aufwand_ertrag_fibu

      def kontrolle
        nil
      end

      def total
        nil
      end
    end
  end
end
