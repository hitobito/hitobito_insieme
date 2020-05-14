# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vertragsperioden::Vp2020
  class TimeRecord::Table

    REPORTS = [Vertragsperioden::Vp2020::TimeRecord::Report::EmployeePensum,
               Vertragsperioden::Vp2020::TimeRecord::Report::EmployeeTime,
               Vertragsperioden::Vp2020::TimeRecord::Report::VolunteerWithoutVerificationTime,
               Vertragsperioden::Vp2020::TimeRecord::Report::VolunteerWithVerificationTime,
               Vertragsperioden::Vp2020::TimeRecord::Report::EmployeeEfforts,
               Vertragsperioden::Vp2020::TimeRecord::Report::EmployeeEffortsPensum,
               Vertragsperioden::Vp2020::TimeRecord::Report::CapitalSubstrate,
               Vertragsperioden::Vp2020::TimeRecord::Report::CapitalSubstrateLimit]

    attr_reader :group, :year

    attr_writer :records

    class << self
      def fields
        CostAccounting::Report::Base::FIELDS
      end
    end

    def initialize(group, year, cost_accounting_table = nil)
      @group = group
      @year = year
      @cost_accounting_table = cost_accounting_table || CostAccounting::Table.new(group, year)
    end

    def reports
      @reports ||= REPORTS.each_with_object({}) do |report, hash|
        hash[report.key] = report.new(self)
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
      if model
        records[report_key] ||=
          model.where(group_id: group.id, year: year).first_or_initialize
      end
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
end