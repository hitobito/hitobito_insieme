# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2015::CostAccounting
  class Table

    REPORTS = [Report::Lohnaufwand,
               Report::Sozialversicherungsaufwand,
               Report::UebrigerPersonalaufwand,
               Report::Honorare,
               Report::TotalPersonalaufwand,
               Report::Raumaufwand,
               Report::UebrigerSachaufwand,
               Report::Abschreibungen,
               Report::TotalAufwand,
               Report::UmlagePersonal,
               Report::UmlageRaeumlichkeiten,
               Report::UmlageVerwaltung,
               Report::TotalUmlagen,
               Report::Vollkosten,
               Report::Leistungsertrag,
               Report::BeitraegeIv,
               Report::SonstigeBeitraege,
               Report::DirekteSpenden,
               Report::IndirekteSpenden,
               Report::DirekteSpendenAusserhalb,
               Report::TotalErtraege,
               Report::Deckungsbeitrag1,
               Report::Deckungsbeitrag2,
               Report::Deckungsbeitrag3,
               Report::Deckungsbeitrag4,
               Report::Unternehmenserfolg].freeze

    SECTION_FIELDS = %w(raeumlichkeiten
                      verwaltung
                      beratung
                      treffpunkte
                      blockkurse
                      tageskurse
                      jahreskurse
                      lufeb
                      mittelbeschaffung).freeze

    VISIBLE_REPORTS = REPORTS

    attr_reader :group, :year

    class << self
      def fields
        Report::Base::FIELDS
      end
    end

    def initialize(group, year)
      @group = group
      @year = year
    end

    def section_fields
      SECTION_FIELDS
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
