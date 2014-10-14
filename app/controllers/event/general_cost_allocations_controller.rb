# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::GeneralCostAllocationsController < ReportingBaseController

  private

  def entry
    @entry ||= Event::GeneralCostAllocation.where(group_id: group.id, year: year).
                                            first_or_initialize
  end

  def group
    @group ||= Group.find(params[:group_id])
  end

  def permitted_params
    params.require(:event_general_cost_allocation).
           permit(:general_costs_blockkurse,
                  :general_costs_tageskurse,
                  :general_costs_semesterkurse)
  end

  def show_path
    edit_general_cost_allocation_group_events_path(group, year)
  end

end
