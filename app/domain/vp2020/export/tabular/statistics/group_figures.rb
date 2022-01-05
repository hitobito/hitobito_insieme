# frozen_string_literal: true

#  Copyright (c) 2014-2022, Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Vp2020::Export
  module Tabular
    module Statistics
      class GroupFigures
        include Vertragsperioden::Domain
        delegate :year, to: :figures

        class << self
          def csv(figures)
            Export::Csv::Generator.new(new(figures)).call
          end
        end

        attr_reader :figures

        # See Vp2020::Statistics::GroupFigures
        def initialize(figures)
          @figures = figures
        end

        def data_rows(_format = nil)
          return enum_for(:data_rows) unless block_given?

          figures.groups.each do |group|
            yield values(group)
          end
        end

        def labels
          labels = [t('name'), t('canton'), t('vid'), t('bsv')]
          append_course_labels(labels)
          append_time_labels(labels)
          append_fte_labels(labels)
          append_cost_accounting_labels(labels)
          labels
        end

        private

        def append_course_labels(labels) # rubocop:disable Metrics/MethodLength
          iterate_courses do |lk, fk|
            lk_label = t("leistungskategorie_#{lk}")
            fk_label = I18n.t("activerecord.attributes.event/course.fachkonzepte.#{fk}")
            labels << vp_t('anzahl_kurse',     leistungskategorie: lk_label, fachkonzept: fk_label)
            labels << vp_t('total_vollkosten', leistungskategorie: lk_label, fachkonzept: fk_label)
            labels << vp_t('tage_behinderte',  leistungskategorie: lk_label, fachkonzept: fk_label)
            labels << vp_t('tage_angehoerige', leistungskategorie: lk_label, fachkonzept: fk_label)
            labels << vp_t('tage_weitere',     leistungskategorie: lk_label, fachkonzept: fk_label)
            labels << vp_t('tage_total',       leistungskategorie: lk_label, fachkonzept: fk_label)
            if lk == 'tp'
              labels << vp_t('betreuungsstunden_total', leistungskategorie: lk_label, fachkonzept: fk_label) # rubocop:disable Metrics/LineLength
            end
          end
        end

        def append_time_labels(labels)
          %w(employees volunteers).each do |type|
            labels << vp_label('kurse_grundlagen', 'fields_full', vp_t("hours_#{type}"))
            %w(grundlagen promoting general specific).each do |section|
              labels << vp_label("lufeb_#{section}", 'lufeb_fields_full', t("lufeb_hours_#{type}"))
            end
            %w(media_grundlagen total_media beratung).each do |section|
              labels << vp_label(section, 'fields_full', vp_t("hours_#{type}"))
            end
          end
          labels << t('lufeb_hours_volunteers_without')
          labels << vp_label('beratung', 'fields_full', vp_t('hours_volunteers_without'))
        end

        def append_fte_labels(labels)
          labels << t('fte_employees_total')
          labels << t('fte_employees_only_art_74')
          labels << t('fte_volunteers_total')
          labels << t('fte_volunteers_only_art_74')
          labels << t('fte_volunteers_with_verification_only_art_74')
        end

        def append_cost_accounting_labels(labels)
          labels << t('geschluesseltes_kapitalsubstrat')
          labels << t('faktor_kapitalsubstrat')
          labels << t('total_aufwand')
          labels << t('vollkosten_nach_umlagen_betrieb')
          labels << t('iv_beitrag')
          labels << t('deckungsbeitrag_4')
        end

        def values(group) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
          values = [group.full_name.presence || group.name,
                    group.canton_label,
                    group.vid,
                    group.bsv_number]

          iterate_courses do |lk, fk|
            append_course_values(values, figures.course_record(group, lk, fk), lk)
          end

          append_time_values(values, figures.employee_time(group))
          append_time_values(values, figures.volunteer_with_verification_time(group))

          values << figures.volunteer_without_verification_time(group).try(:total_lufeb).to_i
          values << figures.volunteer_without_verification_time(group).try(:beratung).to_i

          append_employee_fte_values(values, group)
          append_volunteer_fte_values(values, group)

          append_capital_substrate_values(values, figures.capital_substrate(group))
          append_capital_substrate_factor_values(values, figures.capital_substrate_factor(group))
          append_cost_accounting_values(values, figures.cost_accounting_table(group))

          values
        end

        def append_course_values(values, record, lk = nil) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          values << (record&.anzahl_kurse.to_i       || 0)
          values << (record&.total_vollkosten        || 0.0)
          values << (record&.tage_behinderte         || 0.0)
          values << (record&.tage_angehoerige        || 0.0)
          values << (record&.tage_weitere            || 0.0)
          values << (record&.total_tage_teilnehmende || 0.0)
          values << (record&.betreuungsstunden       || 0.0) if lk == 'tp'
        end

        def append_time_values(values, record) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity
          values << (record&.kurse_grundlagen      || 0)
          values << (record&.lufeb_grundlagen      || 0)
          values << (record&.total_lufeb_promoting || 0)
          values << (record&.total_lufeb_general   || 0)
          values << (record&.total_lufeb_specific  || 0)
          values << (record&.medien_grundlagen     || 0)
          values << (record&.total_media           || 0)
          values << (record&.beratung              || 0)
        end

        def append_employee_fte_values(values, group)
          pensum = figures.employee_pensum(group) || TimeRecord::EmployeePensum.new
          values << pensum.total.to_d
          values << pensum.paragraph_74.to_d
        end

        def append_volunteer_fte_values(values, group)
          with = figures.volunteer_with_verification_time(group)
          without = figures.volunteer_without_verification_time(group)
          records = [with, without].compact

          values << records.sum(&:total_pensum).to_d
          values << records.sum(&:total_paragraph_74_pensum).to_d
          values << with.try(:total_paragraph_74_pensum).to_d
        end

        def append_capital_substrate_values(values, report)
          values << report.paragraph_74
        end

        def append_capital_substrate_factor_values(values, report)
          values << report.paragraph_74
        end

        def append_cost_accounting_values(values, table)
          if table
            values << table.value_of('total_aufwand',    'aufwand_ertrag_fibu')
            values << table.value_of('vollkosten',       'total')
            values << table.value_of('beitraege_iv',     'total')
            values << table.value_of('deckungsbeitrag4', 'total')
          else
            values << 0.0 << 0.0 << 0.0 << 0.0
          end
        end

        def iterate_courses(&block)
          figures
            .leistungskategorien
            .product(figures.fachkonzepte)
            .keep_if { |(lk, fk)| valid_lk_fk_combination(lk, fk) }
            .each(&block)
        end

        def valid_lk_fk_combination(lk, fk) # rubocop:disable Naming/MethodParameterName
          (lk.to_s == 'tp' && fk.to_s == 'treffpunkt') ||
            (lk.to_s != 'tp' && fk.to_s != 'treffpunkt')
        end

        def vp_label(section, scope, prefix)
          vp_t(section, scope: vp_i18n_scope(scope)).prepend(prefix + ': ')
        end

        def vp_t(field, options = {})
          I18n.t(field, { scope: vp_i18n_scope('statistics.group_figures') }.merge(options))
        end

        def t(field, options = {})
          I18n.t("statistics.group_figures.#{field}", options)
        end
      end
    end
  end
end
