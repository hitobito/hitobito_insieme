# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export
  module Csv
    module CourseReporting
      class Aggregation

        ATTRIBUTES = [
          :anzahl_kurse,
          :kursdauer,

          :teilnehmende,
          :teilnehmende_behinderte,
          :teilnehmende_angehoerige,
          :teilnehmende_weitere,

          :total_absenzen,
          :absenzen_behinderte,
          :absenzen_angehoerige,
          :absenzen_weitere,

          :total_tage_teilnehmende,
          :tage_behinderte,
          :tage_angehoerige,
          :tage_weitere,

          :betreuende,
          :leiterinnen,
          :fachpersonen,
          :hilfspersonal_ohne_honorar,
          :hilfspersonal_mit_honorar,
          :kuechenpersonal,

          :direkter_aufwand,
          :honorare_inkl_sozialversicherung,
          :unterkunft,
          :uebriges,

          :direkte_kosten_pro_le,
          :total_vollkosten,
          :vollkosten_pro_le,
          :beitraege_teilnehmende,
          :betreuungsschluessel,
          :anzahl_spezielle_unterkunft
        ]

        class << self
          def export(aggregation)
            Export::Csv::Generator.new(new(aggregation)).csv
          end
        end

        attr_reader :aggregation

        def initialize(aggregation)
          @aggregation = aggregation
        end

        def to_csv(generator)
          generator << labels
          ATTRIBUTES.each do |attr|
            generator << attributes(attr)
          end
        end

        private

        def labels
          values('') do |kriterium, kursart|
            if kriterium == 'all'
              kursart_label(kursart)
            else
              "#{t(kriterium)} #{kursart_label(kursart)}"
            end
          end
        end

        def t(attr)
          if jahreskurs?
            I18n.t("course_reporting.aggregations.#{attr}_stunden",
                   default: :"course_reporting.aggregations.#{attr}")
          else
            I18n.t("course_reporting.aggregations.#{attr}")
          end
        end

        def kursart_label(kursart)
          if kursart == 'total'
            I18n.t('course_reporting.aggregations.total')
          else
            I18n.t("activerecord.attributes.event/course_record.kursarten.#{kursart}")
          end
        end

        def attributes(attr)
          values(t(attr)) do |kriterium, kursart|
            aggregation.course_counts(kriterium, kursart, attr)
          end
        end

        def values(label)
          [label].tap do |result|
            each_column do |kriterium, kursart|
              result << yield(kriterium, kursart)
            end
          end
        end

        def each_column(&block)
          kriterien.
            product(kursarten).
            append(%w(all total)).
            each(&block)
        end

        def kriterien
          if blockkurs? || tageskurs?
            aggregation.inputkriterien
          else
            %w(all)
          end
        end

        def kursarten
          if blockkurs? || tageskurs?
            aggregation.kursarten + %w(total)
          else
            aggregation.kursarten
          end
        end

        def blockkurs?
          aggregation.leistungskategorie == 'bk'
        end

        def tageskurs?
          aggregation.leistungskategorie == 'tk'
        end

        def jahreskurs?
          aggregation.leistungskategorie == 'sk'
        end

      end
    end
  end
end
