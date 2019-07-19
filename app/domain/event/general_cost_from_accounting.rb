# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::GeneralCostFromAccounting

  LEISTUNGSKATEGORIE_MAPPING = { 'bk' => 'blockkurse',
                                 'tk' => 'tageskurse',
                                 'sk' => 'jahreskurse',
                                 'tp' => 'treffpunkte' }

  def initialize(group, year)
    @table = CostAccounting::Table.new(group, year)
  end

  def general_cost(leistungskategorie)
    field = LEISTUNGSKATEGORIE_MAPPING.fetch(leistungskategorie)

    @table.value_of('lohnaufwand', field).to_d +
    @table.value_of('sozialversicherungsaufwand', field).to_d +
    @table.value_of('uebriger_personalaufwand', field).to_d +
    @table.value_of('umlage_raeumlichkeiten', field).to_d +
    @table.value_of('umlage_verwaltung', field).to_d
  end

end
