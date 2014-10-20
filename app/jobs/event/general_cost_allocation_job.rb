# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::GeneralCostAllocationJob < BaseJob

  self.parameters = [:general_cost_allocation_id]

  def initialize(general_cost_allocation_id)
    @general_cost_allocation_id = general_cost_allocation_id
  end

  def perform
    general_cost_allocation.considered_course_records.includes(:event).find_each do |record|
      record.update!(gemeinkostenanteil: calculate_gemeinkostenanteil(record),
                     gemeinkosten_updated_at: general_cost_allocation.updated_at)
    end
  end

  private

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
