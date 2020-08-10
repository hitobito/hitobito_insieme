# frozen_string_literal: true

#  Copyright (c) 2020 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020
  module Export
    module Tabular
      module TimeRecords
        class List
          include Vertragsperioden::Domain

          ATTRIBUTES = [
            :lufeb_grundlagen,

            :beratung_fachhilfeorganisationen,
            :unterstuetzung_leitorgane,
            :freiwilligen_akquisition,
            :total_lufeb_promoting,

            :auskuenfte,
            :referate,
            :medien_zusammenarbeit,
            :sensibilisierungskampagnen,
            :total_lufeb_general,

            :erarbeitung_grundlagen,
            :gremien,
            :vernehmlassungen,
            :projekte,
            :total_lufeb_specific,

            :total_lufeb,

            :medien_grundlagen,
            :website,
            :newsletter,
            :videos,
            :social_media,
            :beratungsmodule,
            :apps,
            :total_media,

            :kurse_grundlagen,
            :blockkurse,
            :tageskurse,
            :jahreskurse,
            :treffpunkte,
            :total_courses,

            :beratung,
            :total_additional_person_specific,

            :mittelbeschaffung,
            :verwaltung,
            :total_remaining,

            :total_paragraph_74,
            :total_paragraph_74_pensum,

            :total_not_paragraph_74,
            :total_not_paragraph_74_pensum,

            :total,
            :total_pensum
          ].freeze

          PENSUM_ATTRIBUTES = [
            :paragraph_74,
            :not_paragraph_74,
            :total
          ].freeze

          class << self
            def csv(records)
              ::Export::Csv::Generator.new(new(records)).call
            end
          end

          attr_reader :records, :year

          def initialize(records)
            @records = records.index_by { |r| r.class.key }
            @year = 2020 # hardcoded to vp2020
          end

          def data_rows(_format = nil)
            return enum_for(:data_rows) unless block_given?

            PENSUM_ATTRIBUTES.each do |attr|
              yield pensum_attributes(attr)
            end
            ATTRIBUTES.each do |attr|
              yield attributes(attr)
            end
          end

          def labels
            [nil,
             ::TimeRecord::EmployeeTime.model_name.human,
             ::TimeRecord::VolunteerWithVerificationTime.model_name.human,
             ::TimeRecord::VolunteerWithoutVerificationTime.model_name.human]
          end

          private

          def pensum_attributes(attr)
            [::TimeRecord::EmployeePensum.human_attribute_name(attr),
             records['employee_time'].try(:employee_pensum).try(attr),
             nil,
             nil]
          end

          def attributes(attr)
            [label(::TimeRecord, attr),
             value(::TimeRecord::EmployeeTime, attr),
             value(::TimeRecord::VolunteerWithVerificationTime, attr),
             value(::TimeRecord::VolunteerWithoutVerificationTime, attr)]
          end

          def label(klass, attr)
            I18n.t(attr,
                   scope: vp_i18n_scope(klass.name.tableize),
                   default: [
                     klass.human_attribute_name(attr)
                   ])
          end

          def value(klass, attr)
            records[klass.key].try(attr)
          end

        end
      end
    end
  end
end
