# frozen_string_literal: true
#  Copyright (c) 2016 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export
  module Tabular
    module TimeRecords
      class Vereinsliste < Export::Tabular::Base

        ATTRS_LUFEB = [
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
          :total_lufeb_promoting
        ]

        ATTRS_LUFEB_SUM = [
          :total_lufeb_general,
          :total_lufeb_private,
          :total_lufeb_specific,
          :total_lufeb_promoting
        ]

        ATTRS_GENERAL = [
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
          :total_not_paragraph_74,

          :total
        ]

        self.model_class = TimeRecord

        attr_reader :liste

        def initialize(liste)
          super(liste.vereine)
          @liste = liste
        end

        private

        def attributes
          [:group].tap do |attrs|
            if liste.type == TimeRecord::VolunteerWithoutVerificationTime.sti_name
              attrs.concat(ATTRS_LUFEB_SUM)
            else
              attrs.concat(ATTRS_LUFEB)
            end
            attrs.concat(ATTRS_GENERAL)
          end
        end

        def row_for(verein, _format = nil)
          Row.new(verein, liste.time_record(verein))
        end

        class Row

          attr_reader :verein, :record

          def initialize(verein, record)
            @verein = verein
            @record = record
          end

          def fetch(attr)
            if attr == :group
              verein.to_s
            elsif record
              record.send(attr)
            end
          end

        end

      end
    end
  end
end
