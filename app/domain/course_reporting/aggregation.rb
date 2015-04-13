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
      :kuechenpersonal,

      :honorare_inkl_sozialversicherung,
      :unterkunft,
      :uebriges,

      :beitraege_teilnehmende,
      :gemeinkostenanteil,
      :total_direkte_kosten,
    ]

    RUBY_SUMMED_ATTRS = COUNTS + [
      :anzahl_spezielle_unterkunft,
      :tage_behinderte, :tage_angehoerige, :tage_weitere,
      :direkte_kosten_pro_le, :vollkosten_pro_le,
      :betreuungsschluessel
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
      Event::CourseRecord::KURSARTEN
    end

    def inputkriterien
      Event::CourseRecord::INPUTKRITERIEN
    end

    def scope
      Event::CourseRecord.
        joins(:event).
        group(:kursart).
        group(:inputkriterien).
        merge(Event.in_year(year)).
        merge(Event.with_group_id(group_id)).
        where(events: { leistungskategorie: leistungskategorie },
              event_course_records: { zugeteilte_kategorie: zugeteilte_kategorien,
                                      subventioniert: subventioniert })
    end

    private

    def data
      @data ||= begin
        hash = Hash.new {|k, v| k[v] = {} }
        build_categories(hash)
        build_totals(hash)
        hash
      end
    end

    def build_categories(hash)
      inputkriterien.each do |kriterium|
        hash[kriterium]['total'] = sum(records_for(:inputkriterien, kriterium))
        kursarten.each { |kursart| hash[kriterium][kursart] = find_record(kriterium, kursart) }
      end
    end

    def build_totals(hash)
      hash['all']['total'] = sum(records)
      kursarten.each { |kursart| hash['all'][kursart] = sum(records_for(:kursart, kursart)) }
    end

    def records_for(attr, value)
      records.select { |record| record.send(attr) == value }
    end

    def find_record(inputkriterium, kursart)
      records_for(:inputkriterien, inputkriterium).
        find( -> { empty_course_record }) { |r| r.kursart == kursart }
    end

    def records
      @records ||= scope.select(select)
    end

    def empty_course_record
      Event::CourseRecord.new(anzahl_kurse: nil)
    end

    def sum(course_records)
      RUBY_SUMMED_ATTRS.each_with_object(empty_course_record) do |attr, total|
        values = course_records.collect { |record| record.send(attr) }
        summed = values.compact.inject { |sum, val| val + sum }
        total.send("#{attr}=", summed)
      end
    end

    def select
      plains = [ 'event_course_records.year',
                 'event_course_records.kursart',
                 'event_course_records.inputkriterien' ]

      (plains + sql_summed_attrs + sql_sum_unterkunft).join(', ')
    end

    def sql_summed_attrs
      COUNTS.map {|sym| "sum(#{sym}) as #{sym}" }
    end

    def sql_sum_unterkunft
      column = Event::CourseRecord.column_types['spezielle_unterkunft']
      quoted_true_value = Event::CourseRecord.connection.quote(true, column)
      Array(["sum(CASE WHEN event_course_records.spezielle_unterkunft = #{quoted_true_value}",
             "THEN event_course_records.anzahl_kurse ELSE 0 END)",
             "as anzahl_spezielle_unterkunft_db"].join(' '))
    end

  end
end
