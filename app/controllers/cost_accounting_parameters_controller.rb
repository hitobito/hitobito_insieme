# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


class CostAccountingParametersController < SimpleCrudController
  include YearBasedPaging

  self.permitted_attrs = [:id, :year, :kat1_bk, :kat2_tk]

  self.sort_mappings = { year: 'cost_accounting_parameters.year',
                         kat1_bk: 'cost_accounting_parameters.kat1_bk',
                         kat2_tk: 'cost_accounting_parameters.kat2_tk' }


  def list_entries
    super.order(:year)
  end

end
