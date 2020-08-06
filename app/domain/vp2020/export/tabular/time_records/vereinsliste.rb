# frozen_string_literal: true

#  Copyright (c) 2020 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Vp2020::Export
  module Tabular
    module TimeRecords
      class Vereinsliste < Export::Tabular::Base
        include Vertragsperioden::Domain

        ATTRS_LUFEB = [
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
          :total_lufeb_specific
        ].freeze

        ATTRS_LUFEB_SUM = [
          :lufeb_grundlagen,
          :total_lufeb_promoting,
          :total_lufeb_general,
          :total_lufeb_specific
        ].freeze

        ATTRS_GENERAL = [
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
          :total_not_paragraph_74,

          :total
        ].freeze

        self.model_class = TimeRecord

        attr_reader :liste, :year

        def initialize(liste)
          super(liste.vereine)
          @liste = liste
          @year  = 2020
        end

        def attribute_label(attr)
          I18n.t(attr,
                 scope: vp_i18n_scope(model_class.name.tableize),
                 default: [
                   human_attribute(attr)
                 ])
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
