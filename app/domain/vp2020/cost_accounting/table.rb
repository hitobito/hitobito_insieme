# frozen_string_literal: true

#  Copyright (c) 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020::CostAccounting
  class Table

    REPORTS = [CostAccounting::Report::Lohnaufwand,
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
               CostAccounting::Report::BeitraegeIv,
               CostAccounting::Report::SonstigeBeitraege,
               CostAccounting::Report::DirekteSpenden,
               CostAccounting::Report::IndirekteSpenden,
               CostAccounting::Report::DirekteSpendenAusserhalb,
               CostAccounting::Report::TotalErtraege,
               CostAccounting::Report::Deckungsbeitrag1,
               CostAccounting::Report::Deckungsbeitrag2,
               CostAccounting::Report::Deckungsbeitrag3,
               CostAccounting::Report::Deckungsbeitrag4,
               CostAccounting::Report::Unternehmenserfolg]

    VISIBLE_REPORTS = [CostAccounting::Report::Lohnaufwand,
                       CostAccounting::Report::Sozialversicherungsaufwand,
                       CostAccounting::Report::UebrigerPersonalaufwand,
                       CostAccounting::Report::Honorare,
                       CostAccounting::Report::TotalPersonalaufwand,
                       CostAccounting::Report::Raumaufwand,
                       CostAccounting::Report::UebrigerSachaufwand,
                       CostAccounting::Report::TotalAufwand,
                       CostAccounting::Report::TotalUmlagen,
                       CostAccounting::Report::Vollkosten,
                       CostAccounting::Report::Leistungsertrag,
                       CostAccounting::Report::BeitraegeIv,
                       CostAccounting::Report::SonstigeBeitraege,
                       CostAccounting::Report::DirekteSpenden,
                       CostAccounting::Report::IndirekteSpenden,
                       CostAccounting::Report::TotalErtraege,
                       CostAccounting::Report::Deckungsbeitrag4,
                       CostAccounting::Report::Unternehmenserfolg]

    attr_reader :group, :year

    class << self
      def fields
        CostAccounting::Report::Base::FIELDS - %w(abschreibungen)
      end
    end

    def initialize(group, year)
      @group = group
      @year = year
    end

    def time_record
      @time_record ||= TimeRecord::EmployeeTime.where(group_id: group.id, year: year).
                                                first_or_initialize
    end

    def reports
      @reports ||= REPORTS.each_with_object({}) do |report, hash|
        hash[report.key] = report.new(self)
      end
    end

    def visible_reports
      @visible_reports ||= VISIBLE_REPORTS.map { |report| [report.key, reports[report.key]] }.to_h
    end

    def course_costs(report_key, leistungskategorie)
      @course_costs ||= prepare_course_costs
      @course_costs[leistungskategorie][report_key]
    end

    def value_of(report, field)
      reports.fetch(report).send(field)
    end

    def cost_record(report_key)
      cost_records[report_key] ||=
        CostAccountingRecord.new(group_id: group.id, year: year, report: report_key)
    end

    def set_records(time_record, cost_records, course_costs)
      @time_record = time_record || TimeRecord::EmployeeTime.new(group_id: group.id, year: year)
      @cost_records = cost_records || {}
      @course_costs = course_costs || Hash.new { |h, k| h[k] = {} }
    end

    private

    def cost_records
      @cost_records ||= begin
        records = CostAccountingRecord.calculation_fields.where(group_id: group.id, year: year)
        records.each_with_object({}) { |r, hash| hash[r.report] = r }
      end
    end

    def prepare_course_costs
      nested_hash = Hash.new { |h, k| h[k] = {} }
      load_course_costs.
        each_with_object(nested_hash) do |(lk, honorare, unterkunft, uebriges), hash|
        hash[lk] = { 'honorare'             => honorare,
                     'raumaufwand'          => unterkunft,
                     'uebriger_sachaufwand' => uebriges }
      end
    end

    def load_course_costs
      Event::CourseRecord.
        joins(:event).
        group('events.leistungskategorie').
        where(year: year, subventioniert: true).
        merge(Event.with_group_id(group.id)).
        pluck('leistungskategorie, ' \
              'SUM(honorare_inkl_sozialversicherung), SUM(unterkunft), SUM(uebriges)')
    end

  end
end
