# frozen_string_literal: true

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2015
  module Export
    module Tabular
      module TimeRecords
        class List

          ATTRIBUTES = [
            :kontakte_medien,
            :interviews,
            :publikationen,
            :referate,
            :medienkonferenzen,
            :informationsveranstaltungen,
            :sensibilisierungskampagnen,
            :allgemeine_auskunftserteilung,
            :kontakte_meinungsbildner,
            :beratung_medien,
            :total_lufeb_general,

            :eigene_zeitschriften,
            :newsletter,
            :informationsbroschueren,
            :eigene_webseite,
            :total_lufeb_private,

            :erarbeitung_instrumente,
            :erarbeitung_grundlagen,
            :projekte,
            :vernehmlassungen,
            :gremien,
            :total_lufeb_specific,

            :auskunftserteilung,
            :vermittlung_kontakte,
            :unterstuetzung_selbsthilfeorganisationen,
            :koordination_selbsthilfe,
            :treffen_meinungsaustausch,
            :beratung_fachhilfeorganisationen,
            :unterstuetzung_behindertenhilfe,
            :total_lufeb_promoting,

            :total_lufeb,

            :blockkurse,
            :tageskurse,
            :jahreskurse,
            :total_courses,

            :treffpunkte,
            :beratung,
            :total_additional_person_specific,

            :verwaltung,
            :mittelbeschaffung,
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

          attr_reader :records

          def initialize(records)
            @records = records.index_by { |r| r.class.key }
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
            [::TimeRecord.human_attribute_name(attr),
             value(::TimeRecord::EmployeeTime, attr),
             value(::TimeRecord::VolunteerWithVerificationTime, attr),
             value(::TimeRecord::VolunteerWithoutVerificationTime, attr)]
          end

          def value(klass, attr)
            records[klass.key].try(attr)
          end

        end
      end
    end
  end
end
