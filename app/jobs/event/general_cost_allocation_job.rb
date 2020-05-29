#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::GeneralCostAllocationJob < BaseJob

  self.parameters = [:general_cost_allocation_id]

  def initialize(general_cost_allocation)
    @general_cost_allocation_id = general_cost_allocation.id
  end

  def perform
    Event::CourseRecord.transaction do
      update_subsidized
      update_not_subsidized
    end
  end

  private

  def update_subsidized
    general_cost_allocation.considered_course_records.includes(:event).find_each do |record|
      record.update!(gemeinkostenanteil: calculate_gemeinkostenanteil(record),
                     gemeinkosten_updated_at: general_cost_allocation.updated_at)
    end
  end

  def update_not_subsidized
    general_cost_allocation.considered_course_records(false).find_each do |record|
      # update each individually to trigger after_save kategorie calculations.
      record.update!(gemeinkostenanteil: 0,
                     gemeinkosten_updated_at: general_cost_allocation.updated_at)
    end
  end

  def calculate_gemeinkostenanteil(record)
    allowance = general_cost_allocation.general_costs_allowance(record.event.leistungskategorie)
    if allowance
      record.direkter_aufwand * allowance
    end
  end

  def general_cost_allocation
    @general_cost_allocation ||= Event::GeneralCostAllocation.find(@general_cost_allocation_id)
  end

end
