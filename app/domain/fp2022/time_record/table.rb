# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2022
  class TimeRecord::Table

    REPORTS = [Fp2022::TimeRecord::Report::EmployeePensum,
               Fp2022::TimeRecord::Report::EmployeeTime,
               Fp2022::TimeRecord::Report::VolunteerWithoutVerificationTime,
               Fp2022::TimeRecord::Report::VolunteerWithVerificationTime,
               Fp2022::TimeRecord::Report::EmployeeEfforts,
               Fp2022::TimeRecord::Report::EmployeeEffortsPensum,
               Fp2022::TimeRecord::Report::CapitalSubstrate,
               Fp2022::TimeRecord::Report::CapitalSubstrateLimit,
               Fp2022::TimeRecord::Report::CapitalSubstrateFactor].freeze

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
