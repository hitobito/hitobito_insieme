# frozen_string_literal: true

#  Copyright (c) 2020-2021, Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# V11 policy for BSV-Vertragsperiode 2024-2028.
# It includes Grundlagenarbeit only for Leistungskategorie TP.
module Policies
  module Fsio2428
    class V11
      def self.label
        "BSV2428/V11"
      end

      # Stop adding Grundlagenarbeit to export client_statistics for
      # the leistungskategorien  sk, bk and tk, but keep adding for tp.
      def include_grundlagen_hours_for?(fachkonzept)
        fachkonzept == "treffpunkt"
      end
    end
  end
end
