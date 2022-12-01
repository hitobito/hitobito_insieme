# frozen_string_literal: true

#  Copyright (c) 2014-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: event_general_cost_allocations
#
#  id                          :integer          not null, primary key
#  group_id                    :integer          not null
#  year                        :integer          not null
#  general_costs_blockkurse    :decimal(12, 2)
#  general_costs_tageskurse    :decimal(12, 2)
#  general_costs_semesterkurse :decimal(12, 2)
#  general_costs_treffpunkte   :decimal(12, 2)
#  created_at                  :datetime
#  updated_at                  :datetime
#
class Event::GeneralCostAllocationsController < ReportingBaseController

  include Featureperioden::Views

  helper_method :general_cost_from_accounting

  after_save :schedule_allocation_job

  def show
    respond_to do |format|
      format.html { redirect_to edit_general_cost_allocation_group_events_path(group, year) }
      format.csv do
        send_data Export::Tabular::Events::GeneralCostAllocation.csv(entry), type: :csv
      end
    end
  end

  private

  def entry
    @entry ||= Event::GeneralCostAllocation.where(group_id: group.id, year: year)
                                           .first_or_initialize
  end

  def group
    @group ||= Group.find(params[:group_id])
  end

  def general_cost_from_accounting
    @general_cost_from_accounting ||= Event::GeneralCostFromAccounting.new(group, year)
  end

  def permitted_params
    params.require(:event_general_cost_allocation)
          .permit(:general_costs_blockkurse,
                  :general_costs_tageskurse,
                  :general_costs_semesterkurse,
                  :general_costs_treffpunkte)
  end

  def show_path
    edit_general_cost_allocation_group_events_path(group, year)
  end

  def set_success_notice
    flash[:notice] = I18n.t('event.general_cost_allocations.update.flash.success', model: entry)
  end

  def schedule_allocation_job
    Event::GeneralCostAllocationJob.new(entry).enqueue!
  end

end
