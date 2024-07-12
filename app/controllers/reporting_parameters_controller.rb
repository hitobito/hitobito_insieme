# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: reporting_parameters
#
#  id                                :integer          not null, primary key
#  year                              :integer          not null
#  vollkosten_le_schwelle1_blockkurs :decimal(12, 2)   not null
#  vollkosten_le_schwelle2_blockkurs :decimal(12, 2)   not null
#  vollkosten_le_schwelle1_tageskurs :decimal(12, 2)   default(0.0), not null
#  vollkosten_le_schwelle2_tageskurs :decimal(12, 2)   default(0.0), not null
#  bsv_hours_per_year                :integer          not null
#  capital_substrate_exemption       :decimal(12, 2)   not null
#

class ReportingParametersController < SimpleCrudController
  self.permitted_attrs = [:id,
    :year,
    :vollkosten_le_schwelle1_blockkurs,
    :vollkosten_le_schwelle2_blockkurs,
    :vollkosten_le_schwelle1_tageskurs,
    :vollkosten_le_schwelle2_tageskurs,
    :bsv_hours_per_year,
    :capital_substrate_exemption,
    :capital_substrate_limit]

  private

  def list_entries
    super.list
  end
end
