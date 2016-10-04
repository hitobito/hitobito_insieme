# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export
  module Csv
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
          :auskunftserteilung,
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

          :nicht_art_74_leistungen,
          :total_not_paragraph_74,
          :total_not_paragraph_74_pensum,

          :total,
          :total_pensum
        ]

        PENSUM_ATTRIBUTES = [
          :paragraph_74,
          :not_paragraph_74,
          :total
        ]

        class << self
          def export(records)
            Export::Csv::Generator.new(new(records)).csv
          end
        end

        attr_reader :records

        def initialize(records)
          @records = records.each_with_object({}) { |r, hash| hash[r.class.key] = r }
        end

        def to_csv(generator)
          generator << labels
          PENSUM_ATTRIBUTES.each do |attr|
            generator << pensum_attributes(attr)
          end
          ATTRIBUTES.each do |attr|
            generator << attributes(attr)
          end
        end

        private

        def labels
          [nil,
           TimeRecord::EmployeeTime.model_name.human,
           TimeRecord::VolunteerWithVerificationTime.model_name.human,
           TimeRecord::VolunteerWithoutVerificationTime.model_name.human]
        end

        def pensum_attributes(attr)
          [TimeRecord::EmployeePensum.human_attribute_name(attr),
           records['employee_time'].try(:employee_pensum).try(attr),
           nil,
           nil]
        end

        def attributes(attr)
          [TimeRecord.human_attribute_name(attr),
           value(TimeRecord::EmployeeTime, attr),
           value(TimeRecord::VolunteerWithVerificationTime, attr),
           value(TimeRecord::VolunteerWithoutVerificationTime, attr)]
        end

        def value(klass, attr)
          records[klass.key].try(attr)
        end

      end
    end
  end
end
