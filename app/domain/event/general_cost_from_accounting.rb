# frozen_string_literal: true

#  Copyright (c) 2014-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::GeneralCostFromAccounting
  include Featureperioden::Domain

  attr_accessor :year

  LEISTUNGSKATEGORIE_MAPPING = {"bk" => "blockkurse",
                                "tk" => "tageskurse",
                                "sk" => "jahreskurse",
                                "tp" => "treffpunkte"}.freeze

  def initialize(group, year)
    @year = year
    @table = fp_class("CostAccounting::Table").new(group, year)
  end

  def general_cost(leistungskategorie)
    @table.general_costs(LEISTUNGSKATEGORIE_MAPPING.fetch(leistungskategorie))
  end
end
