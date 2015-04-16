# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class TimeRecord::Table

  REPORTS =  [TimeRecord::Report::EmployeePensum,
              TimeRecord::Report::EmployeeTime,
              TimeRecord::Report::VolunteerWithoutVerificationTime,
              TimeRecord::Report::VolunteerWithVerificationTime,
              TimeRecord::Report::EmployeeEfforts,
              TimeRecord::Report::EmployeeEffortsPensum,
              TimeRecord::Report::CapitalSubstrate,
              TimeRecord::Report::CapitalSubstrateLimit
             ].each_with_object({}) { |r, hash| hash[r.key] = r }

  attr_reader :group, :year

  def initialize(group, year)
    @group = group
    @year = year
    @cost_accounting_table = CostAccounting::Table.new(group, year)
  end

  def reports
    @reports ||= REPORTS.each_with_object({}) do |entry, hash|
      hash[entry.first] = entry.last.new(self)
    end
  end

  def value_of(report, field)
    reports.fetch(report).send(field)
  end

  def cost_accounting_value_of(report, field)
    @cost_accounting_table.value_of(report, field)
  end

  def record(report_key)
    model = record_model(report_key)
    records[report_key] ||= model && model.where(group_id: group.id, year: year).
      first_or_initialize
  end

  private

  def records
    @records ||= {}
  end

  def record_model(report_key)
    report_key.camelize.constantize
  rescue NameError
    begin
      "TimeRecord::#{report_key.camelize}".constantize
    rescue NameError
      nil
    end
  end

end
