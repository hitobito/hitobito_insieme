# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CostAccounting
  class Aggregation

    TIME_RECORD_COLUMNS = TimeRecord.column_names - %w(id group_id year)

    COST_ACCOUNTING_RECORD_COLUMNS = CostAccountingRecord.column_names -
                                     %w(id group_id year report aufteilung_kontengruppen)

    attr_reader :year

    def initialize(year)
      @year = year
      build_tables
    end

    def value_of(report, field)
      values = @tables.collect { |t| t.value_of(report, field) }
      if values.compact.present?
        values.sum(&:to_d)
      end
    end

    def reports
      @reports ||= Table::REPORTS.each_with_object({}) do |report, hash|
        hash[report.key] = Report.new(report.key, report.kontengruppe, self)
      end
    end

    private

    def build_tables
      groups = (time_records.keys + cost_records.keys).uniq
      @tables = groups.collect do |group|
        Table.new(group, year).tap do |t|
          t.set_records(time_records[group], cost_records[group])
        end
      end
    end

    def time_records
      @time_record ||= begin
        records = TimeRecord::EmployeeTime.where(year: year).includes(:group)
        records.each_with_object({}) { |r, hash| hash[r.group] = r }
      end
    end

    def cost_records
      @cost_records ||= begin
        records = CostAccountingRecord.where(year: year).calculation_fields.includes(:group)
        hash = Hash.new { |h, k| h[k] = {} }
        records.each { |r| hash[r.group][r.report] = r }
        hash
      end
    end

    class Report
      attr_reader :key, :kontengruppe

      def initialize(key, kontengruppe, aggregation)
        @key = key
        @kontengruppe = kontengruppe
        @aggregation = aggregation
      end

      Table.fields.each do |field|
        define_method(field) do
          @aggregation.value_of(key, field)
        end
      end

      def short_name
        I18n.t("cost_accounting.report.#{key}.short_name")
      end

      def human_name
        I18n.t("cost_accounting.report.#{key}.name")
      end
    end

  end
end
