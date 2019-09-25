# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CourseReporting
  class Aggregation

    COUNTS = [
      :anzahl_kurse,
      :kursdauer,

      :teilnehmende_behinderte,
      :teilnehmende_angehoerige,
      :teilnehmende_weitere,

      :absenzen_behinderte,
      :absenzen_angehoerige,
      :absenzen_weitere,

      :leiterinnen,
      :fachpersonen,
      :hilfspersonal_ohne_honorar,
      :hilfspersonal_mit_honorar,
      :betreuerinnen,
      :kuechenpersonal,

      :honorare_inkl_sozialversicherung,
      :unterkunft,
      :uebriges,

      :beitraege_teilnehmende,
      :gemeinkostenanteil,
      :direkter_aufwand,

      :tage_behinderte,
      :tage_angehoerige,
      :tage_weitere
    ]

    RUBY_SUMMED_ATTRS = COUNTS + [
      :anzahl_spezielle_unterkunft
    ]

    attr_accessor :group_id, :year, :leistungskategorie, :zugeteilte_kategorien, :subventioniert

    def initialize(group_id, year, leistungskategorie, zugeteilte_kategorien, subventioniert)
      @group_id = group_id
      @year = year
      @leistungskategorie = leistungskategorie
      @zugeteilte_kategorien = zugeteilte_kategorien
      @subventioniert = subventioniert
    end

    def course_counts(inputkriterium, kursart, attr)
      data.fetch(inputkriterium).fetch(kursart).send(attr)
    end

    def kursarten
      return [] if leistungskategorie == 'tp'
      Event::CourseRecord::KURSARTEN
    end

    def inputkriterien
      Event::CourseRecord::INPUTKRITERIEN
    end

    def scope
      Event::CourseRecord.
        joins(:event).
        group(:kursart, :inputkriterien).
        merge(group_id ? Event.with_group_id(group_id) : nil).
        where(events: {
                leistungskategorie: leistungskategorie },
              event_course_records: {
                year: year,
                zugeteilte_kategorie: zugeteilte_kategorien,
                subventioniert: subventioniert })
    end

    private

    def data
      @data ||= begin
        hash = Hash.new { |k, v| k[v] = {} }
        build_categories(hash)
        build_totals(hash)
        hash
      end
    end

    def build_categories(hash)
      inputkriterien.each do |kriterium|
        hash[kriterium]['total'] = total(records_for(:inputkriterien, kriterium))
        kursarten.each do |kursart|
          hash[kriterium][kursart] = find_record(kriterium, kursart)
        end
      end
    end

    def build_totals(hash)
      hash['all']['total'] = total(records)
      kursarten.each do |kursart|
        hash['all'][kursart] = total(records_for(:kursart, kursart))
      end
    end

    def records_for(attr, value)
      records.select { |record| record.send(attr) == value }
    end

    def find_record(inputkriterium, kursart)
      records.find { |r| r.inputkriterien == inputkriterium && r.kursart == kursart } ||
        empty_course_record
    end

    def records
      @records ||= scope.select(select_clause)
    end

    def empty_course_record
      Event::CourseRecord.new(anzahl_kurse: nil)
    end

    def total(course_records)
      RUBY_SUMMED_ATTRS.each_with_object(empty_course_record) do |attr, total|
        sum = course_records.
                collect { |record| record.send(attr) }.
                compact.
                sum
        total.send("#{attr}=", sum)
      end
    end

    def select_clause
      columns = ['event_course_records.year',
                 'event_course_records.kursart',
                 'event_course_records.inputkriterien']
      columns.concat(sql_summed_attrs)
      columns << sql_sum_unterkunft
      columns.join(', ')
    end

    def sql_summed_attrs
      COUNTS.map { |sym| "SUM(#{sym}) AS #{sym}" }
    end

    def sql_sum_unterkunft
      column = Event::CourseRecord.columns_hash['spezielle_unterkunft']
      quoted_true_value = Event::CourseRecord.connection.quote(true, column)
      "SUM(CASE WHEN event_course_records.spezielle_unterkunft = #{quoted_true_value} " \
      'THEN event_course_records.anzahl_kurse ELSE 0 END) ' \
      'AS anzahl_spezielle_unterkunft'
    end

  end
end
