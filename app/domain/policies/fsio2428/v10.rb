# frozen_string_literal: true

#  Copyright (c) 2020-2021, Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# Baseline policy for BSV-Vertragsperiode 2024-2028.
# It includes Grundlagenarbeit for all Leitsungskategorien (Bk, SK, TK, TP)
module Policies
  module Fsio2428
    class V10
      def self.label
        "BSV2428/V10"
      end

      def include_grundlagen_hours_for?(fachkonzept)
        true
      end
    end
  end
end
