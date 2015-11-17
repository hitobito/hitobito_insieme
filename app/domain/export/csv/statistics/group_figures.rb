# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export
  module Csv
    module Statistics
      class GroupFigures

        class << self
          def export(figures)
            Export::Csv::Generator.new(new(figures)).csv
          end
        end

        attr_reader :figures

        def initialize(figures)
          @figures = figures
        end

        def to_csv(generator)
          generator << labels

          figures.groups.each do |group|
            generator << values(group)
          end
        end

        private

        #Zusätzlich Stellenprozente aus Reporting - Basisinformationen (VZÄ angestellte Mitarbeiter (ganze Organisation), VZÄ angestellte Mitarbeiter (Art. 74), VZÄ ehrenamtliche Mitarbeiter (ganze Organisation), VZÄ ehrenamtliche Mitarbeiter (Art. 74))
        #Zusätzliche Spalten: geschlüsseltes Kapitalsubstrat nach Art. 74 , Totaler Aufwand gemäss FIBU, Volkosten nach Umlagen Betrieb Art. 74, IV-Beitrag, Deckungsbeitrag 4

        def labels
          labels = [t('name'), t('canton'), t('vid'), t('bsv')]
          append_course_labels(labels)
          append_time_labels(labels)
          append_fte_labels(labels)
          labels
        end

        def append_course_labels(labels)
          iterate_courses do |lk, cat|
            lk_label = t("leistungskategorie_#{lk}")
            cat_label = t('kategorie', number: cat)
            labels << t('anzahl_kurse', leistungskategorie: lk_label, kategorie: cat_label)
            labels << t('total_vollkosten', leistungskategorie: lk_label, kategorie: cat_label)
            labels << t('tage_behinderte', leistungskategorie: lk_label, kategorie: cat_label)
            labels << t('tage_angehoerige', leistungskategorie: lk_label, kategorie: cat_label)
            labels << t('tage_weitere', leistungskategorie: lk_label, kategorie: cat_label)
            labels << t('tage_total', leistungskategorie: lk_label, kategorie: cat_label)
          end
        end

        def append_time_labels(labels)
          %w(employees volunteers).each do |type|
            prefix = t("lufeb_hours_#{type}")
            labels << prefix + ': ' + I18n.t('time_records.lufeb_fields_full.lufeb_general')
            labels << prefix + ': ' + I18n.t('time_records.lufeb_fields_full.lufeb_private')
            labels << prefix + ': ' + I18n.t('time_records.lufeb_fields_full.lufeb_specific')
            labels << prefix + ': ' + I18n.t('time_records.lufeb_fields_full.lufeb_promoting')
          end
          labels << t('lufeb_hours_volunteers_without')
        end

        def append_fte_labels(labels)
          labels << t('fte_employees_total')
          labels << t('fte_employees_only_art_74')
          labels << t('fte_volunteers_with_verification_total')
          labels << t('fte_volunteers_with_verification_only_art_74')
        end

        def values(group)
          values = [group.full_name.presence || group.name,
                    group.canton_label,
                    group.vid,
                    group.bsv_number]

          iterate_courses do |lk, cat|
            append_course_values(values, figures.course_record(group, lk, cat))
          end

          append_time_values(values, figures.employee_time(group))
          append_time_values(values, figures.volunteer_with_verification_time(group))
          values << figures.volunteer_without_verification_time(group).try(:total_lufeb).to_i

          append_fte_values(values, figures.employee_time(group))
          append_fte_values(values, figures.volunteer_with_verification_time(group))
          values
        end

        def append_course_values(values, record)
          if record
            values << record.anzahl_kurse.to_i
            values << record.total_vollkosten
            values << record.tage_behinderte
            values << record.tage_angehoerige
            values << record.tage_weitere
            values << record.total_tage_teilnehmende
          else
            values << 0 << 0.0 << 0.0 << 0.0 << 0.0 << 0.0
          end
        end

        def append_time_values(values, record)
          if record
            values << record.total_lufeb_general.to_i
            values << record.total_lufeb_private.to_i
            values << record.total_lufeb_specific.to_i
            values << record.total_lufeb_promoting.to_i
          else
            values << 0 << 0 << 0 << 0
          end
        end

        def append_fte_values(values, record)
          if record
            values << record.total_pensum
            values << record.total_paragraph_74_pensum
          else
            values << 0.0 << 0.0
          end
        end

        def iterate_courses
          figures.leistungskategorien.each do |lk|
            figures.kategorien.each do |cat|
              unless lk == 'sk' && %w(2 3).include?(cat)
                yield lk, cat
              end
            end
          end
        end

        def t(field, options = {})
          I18n.t("statistics.group_figures.#{field}", options)
        end
      end
    end
  end
end
