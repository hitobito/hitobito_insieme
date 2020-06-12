# frozen_string_literal: true

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Vp2020::Export
  module Tabular
    module CourseReporting
      class Aggregation

        include Vertragsperioden::Domain

        NON_TP_ATTRIBUTES = %i(
          anzahl_kurse kursdauer

          teilnehmende teilnehmende_behinderte teilnehmende_angehoerige teilnehmende_weitere

          total_absenzen absenzen_behinderte absenzen_angehoerige absenzen_weitere

          total_tage_teilnehmende tage_behinderte tage_angehoerige tage_weitere

          betreuende leiterinnen fachpersonen hilfspersonal_ohne_honorar hilfspersonal_mit_honorar
          kuechenpersonal direkter_aufwand honorare_inkl_sozialversicherung unterkunft uebriges

          direkte_kosten_pro_le total_vollkosten vollkosten_pro_le beitraege_teilnehmende
          betreuungsschluessel anzahl_spezielle_unterkunft
        ).freeze

        TP_ATTRIBUTES = %i(
          anzahl_kurse kursdauer

          teilnehmende teilnehmende_behinderte teilnehmende_angehoerige teilnehmende_weitere

          total_stunden_betreuung

          betreuende leiterinnen fachpersonen hilfspersonal_ohne_honorar hilfspersonal_mit_honorar
          direkter_aufwand honorare_inkl_sozialversicherung unterkunft uebriges

          direkte_kosten_pro_le total_vollkosten vollkosten_pro_le beitraege_teilnehmende
          betreuungsschluessel anzahl_spezielle_unterkunft
        ).freeze

        class << self
          def csv(aggregation)
            Export::Csv::Generator.new(new(aggregation)).call
          end
        end

        attr_reader :aggregation
        delegate :year, to: :aggregation

        def initialize(aggregation)
          @aggregation = aggregation
        end

        def data_rows(_format = nil)
          return enum_for(:data_rows) unless block_given?

          attributes_of_leistungskategorie.each do |attr|
            yield attributes(attr)
          end
        end

        def labels
          values('') do |kriterium, kursart|
            if kriterium == 'all'
              kursart_label(kursart)
            else
              key = "activerecord.attributes.event/course.fachkonzepte.#{kriterium}"
              "#{I18n.t(key)}: #{kursart_label(kursart)}"
            end
          end
        end

        private

        def vp_translation(attr)
          scope = vp_i18n_scope('course_reporting.aggregations')
          if treffpunkt?
            I18n.t("#{attr}_tp", scope: scope, default: [attr.to_sym, t(attr)])
          elsif abrechnung_in_stunden?
            I18n.t("#{attr}_stunden", scope: scope, default: [attr.to_sym, t(attr)])
          else
            I18n.t(attr, scope: scope, default: t(attr))
          end
        end

        def t(attr)
          if abrechnung_in_stunden?
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

        def attributes_of_leistungskategorie
          return TP_ATTRIBUTES if treffpunkt?
          NON_TP_ATTRIBUTES
        end

        def attributes(attr)
          values(vp_translation(attr)) do |kriterium, kursart|
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
            aggregation.kursfachkonzepte
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

        def treffpunkt?
          aggregation.leistungskategorie == 'tp'
        end

        def abrechnung_in_stunden?
          jahreskurs? || treffpunkt?
        end

      end
    end
  end
end
