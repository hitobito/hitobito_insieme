# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CostAccounting
  class Table

    REPORTS =  [CostAccounting::Report::Lohnaufwand,
                CostAccounting::Report::Sozialversicherungsaufwand,
                CostAccounting::Report::UebrigerPersonalaufwand,
                CostAccounting::Report::Honorare,
                CostAccounting::Report::TotalPersonalaufwand,
                CostAccounting::Report::Raumaufwand,
                CostAccounting::Report::UebrigerSachaufwand,
                CostAccounting::Report::Abschreibungen,
                CostAccounting::Report::TotalAufwand,
                CostAccounting::Report::UmlagePersonal,
                CostAccounting::Report::UmlageRaeumlichkeiten,
                CostAccounting::Report::UmlageVerwaltung,
                CostAccounting::Report::TotalUmlagen,
                CostAccounting::Report::Vollkosten,
                CostAccounting::Report::Leistungsertrag,
                CostAccounting::Report::BeitraegeIV,
                CostAccounting::Report::SonstigeBeitraege,
                CostAccounting::Report::DirekteSpenden,
                CostAccounting::Report::IndirekteSpenden,
                CostAccounting::Report::DirekteSpendenAusserhalb,
                CostAccounting::Report::TotalErtraege,
                CostAccounting::Report::Deckungsbeitrag1,
                # CostAccounting::Report::Deckungsbeitrag2,
                # CostAccounting::Report::Deckungsbeitrag3,
                # CostAccounting::Report::Deckungsbeitrag4,
               ].each_with_object({}) { |r, hash| hash[r.key] = r }


    attr_reader :group, :year

    class << self
      def fields
        CostAccounting::Report::Base::FIELDS
      end
    end

    def initialize(group, year)
      @group = group
      @year = year
    end

    def time_record
      @time_record ||= TimeRecord.where(group_id: group.id, year: year).first_or_initialize
    end

    def reports
      @reports ||= REPORTS.each_with_object({}) do |entry, hash|
        hash[entry.first] = entry.last.new(self)
      end
    end

    def value_of(report, field)
      reports.fetch(report).send(field)
    end

    def cost_record(report_key)
      cost_records[report_key] ||=
        CostAccountingRecord.new(group_id: group.id, year: year, report: report_key)
    end

    private

    def cost_records
      @cost_records ||= begin
        records = CostAccountingRecord.calculation_fields.where(group_id: group.id, year: year)
        records.each_with_object({}) { |r, hash| hash[r.report] = r }
      end
    end

  end
end
