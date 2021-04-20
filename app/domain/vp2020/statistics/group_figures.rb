# frozen_string_literal: true

#  Copyright (c) 2015-2021, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020::Statistics
  class GroupFigures
    include Vertragsperioden::Domain

    attr_reader :year

    def initialize(year)
      @year = year
    end

    def groups
      @groups ||= Group.where(type: [Group::Dachverein,
                                     Group::Regionalverein,
                                     Group::ExterneOrganisation].collect(&:sti_name)).order_by_type
    end

    def leistungskategorien
      Event::Reportable::LEISTUNGSKATEGORIEN
    end

    def fachkonzepte
      Event::Reportable::FACHKONZEPTE
    end

    def course_record(group, leistungskategorie, fachkonzept)
      course_records[group.id][leistungskategorie][fachkonzept]
    end

    def employee_time(group)
      time_records[group.id][TimeRecord::EmployeeTime.sti_name]
    end

    def volunteer_with_verification_time(group)
      time_records[group.id][TimeRecord::VolunteerWithVerificationTime.sti_name]
    end

    def volunteer_without_verification_time(group)
      time_records[group.id][TimeRecord::VolunteerWithoutVerificationTime.sti_name]
    end

    def employee_pensum(group)
      employee_pensums[group.id]
    end

    def cost_accounting_table(group)
      cost_accounting.table(group)
    end

    def capital_substrate(group)
      vp_class('TimeRecord::Report::CapitalSubstrate').new(capital_substrate_time_table(group))
    end

    def capital_substrate_factor(group)
      vp_class('TimeRecord::Report::CapitalSubstrateFactor').new(
        capital_substrate_time_table(group)
      )
    end

    private

    def course_records
      @course_records ||= begin
        hash = Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = {} } }
        load_course_records.each do |record|
          hash[record.group_id][record.leistungskategorie][record.fachkonzept] = record
        end
        hash
      end
    end

    def load_course_records
      Event::CourseRecord.select(course_record_columns)
                         .joins(:event)
                         .joins('INNER JOIN events_groups ON events.id = events_groups.event_id')
                         .where(year: year, subventioniert: true)
                         .group('events_groups.group_id, events.leistungskategorie, ' \
                                'events.fachkonzept')
    end

    def course_record_columns
      'events_groups.group_id, events.leistungskategorie, ' \
      'events.fachkonzept, ' \
      'MAX(event_course_records.year) AS year, ' \
      'SUM(anzahl_kurse) AS anzahl_kurse, ' \
      'SUM(tage_behinderte) AS tage_behinderte, ' \
      'SUM(tage_angehoerige) AS tage_angehoerige, ' \
      'SUM(tage_weitere) AS tage_weitere, ' \
      'SUM(direkter_aufwand) AS direkter_aufwand, ' \
      'SUM(betreuungsstunden) AS betreuungsstunden, ' \
      'SUM(gemeinkostenanteil) AS gemeinkostenanteil'
    end

    def time_records
      @time_records ||= begin
        hash = Hash.new { |h, k| h[k] = {} }
        TimeRecord.where(year: year).each do |record|
          hash[record.group_id][record.type] = record
        end
        hash
      end
    end

    def employee_pensums
      @employee_pensums ||= TimeRecord::EmployeePensum
                            .select('*, time_records.group_id AS group_id')
                            .joins(:time_record)
                            .where(time_records: { year: year })
                            .index_by(&:group_id)
    end

    # Vp2020::CostAccounting::Aggregation
    def cost_accounting
      @cost_accounting ||= vp_class('CostAccounting::Aggregation').new(year)
    end

    def capital_substrate_time_table(group)
      cost_table = cost_accounting_table(group) || nil_cost_accounting_table(group)
      substrate = capital_substrates[group.id]
      time_table = vp_class('TimeRecord::Table').new(group, year, cost_table).tap do |t|
        t.records = { vp_class('TimeRecord::Report::CapitalSubstrate').key => substrate }
      end
      time_table
    end

    def nil_cost_accounting_table(group)
      vp_class('CostAccounting::Table').new(group, year).tap do |table|
        table.set_records(nil, nil, nil)
      end
    end

    def capital_substrates
      @capital_substrates ||= begin
        cs_hash = CapitalSubstrate.where(year: year).index_by(&:group_id)
        cs_hash.default_proc = proc do |_hash, key|
          CapitalSubstrate.new(group_id: key, year: year)
        end
        cs_hash
      end
    end

  end
end
