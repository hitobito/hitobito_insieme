# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2020::CostAccounting
  module Report
    class Lohnaufwand < TimeDistributed
      self.kontengruppe = "500"
    end
  end
end
