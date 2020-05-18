# frozen_string_literal: true

#  Copyright (c) 2020, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020
  class TimeRecord::Calculation

    DEFAULT_BSV_HOURS_PER_YEAR = 1900

    attr_reader :record

    def initialize(record)
      @record = record
    end

    delegate :total_lufeb_general,
             :total_lufeb_private,
             :total_lufeb_specific,
             :total_lufeb_promoting,
             :nicht_art_74_leistungen,

             :verwaltung,
             :beratung,
             :treffpunkte,
             :blockkurse,
             :tageskurse,
             :jahreskurse,
             :kontakte_medien,
             :interviews,
             :publikationen,
             :referate,
             :medienkonferenzen,
             :informationsveranstaltungen,
             :sensibilisierungskampagnen,
             :auskunftserteilung,
             :kontakte_meinungsbildner,
             :beratung_medien,
             :eigene_zeitschriften,
             :newsletter,
             :informationsbroschueren,
             :eigene_webseite,
             :erarbeitung_instrumente,
             :erarbeitung_grundlagen,
             :projekte,
             :vernehmlassungen,
             :gremien,
             :vermittlung_kontakte,
             :unterstuetzung_selbsthilfeorganisationen,
             :koordination_selbsthilfe,
             :treffen_meinungsaustausch,
             :beratung_fachhilfeorganisationen,
             :unterstuetzung_behindertenhilfe,
             :mittelbeschaffung,
             :allgemeine_auskunftserteilung,
             :type,
             :year,

             :unterstuetzung_leitorgane,
             :freiwilligen_akquisition,
             :auskuenfte,
             :medien_zusammenarbeit,
             :medien_grundlagen,
             :website,
             :videos,
             :social_media,
             :beratungsmodule,
             :apps,
             :total_lufeb_media,
             :kurse_grundlagen,

             to: :record

    def total_lufeb
      total_lufeb_promoting.to_i +
        total_lufeb_general.to_i +
        total_lufeb_specific.to_i +
        total_lufeb_media.to_i
    end

    def total_courses
      kurse_grundlagen.to_i +
        blockkurse.to_i +
        tageskurse.to_i +
        treffpunkte.to_i +
        jahreskurse.to_i
    end

    def total_additional_person_specific
      beratung.to_i
    end

    def total_remaining
      mittelbeschaffung.to_i +
        verwaltung.to_i
    end

    def total_paragraph_74
      @total_paragraph_74 ||=
        total_lufeb.to_i +
        total_courses.to_i +
        total_additional_person_specific.to_i +
        total_remaining.to_i
    end

    def total_not_paragraph_74
      nicht_art_74_leistungen.to_i
    end

    def total
      total_paragraph_74.to_i +
        total_not_paragraph_74.to_i
    end

    def total_paragraph_74_pensum
      total_paragraph_74.to_d / bsv_hours_per_year
    end

    def total_not_paragraph_74_pensum
      total_not_paragraph_74.to_d / bsv_hours_per_year
    end

    def total_pensum
      total.to_d / bsv_hours_per_year
    end

    def update_totals
      @total_paragraph_74 = nil
      calculate_total_lufeb_promoting
      calculate_total_lufeb_general
      calculate_total_lufeb_specific
      calculate_total_lufeb_media
    end

    private

    def bsv_hours_per_year
      globals ? globals.bsv_hours_per_year : DEFAULT_BSV_HOURS_PER_YEAR
    end

    def globals
      @globals ||= ReportingParameter.for(year)
    end

    def calculate_total_lufeb_promoting
      @record.total_lufeb_promoting =
        beratung_fachhilfeorganisationen.to_i +
        unterstuetzung_leitorgane.to_i +
        freiwilligen_akquisition.to_i
    end

    def calculate_total_lufeb_general
      @record.total_lufeb_general =
        auskuenfte.to_i +
        referate.to_i +
        medien_zusammenarbeit.to_i +
        sensibilisierungskampagnen.to_i
    end

    def calculate_total_lufeb_specific
      @record.total_lufeb_specific =
        erarbeitung_grundlagen.to_i +
        gremien.to_i +
        vernehmlassungen.to_i +
        projekte.to_i
    end

    def calculate_total_lufeb_media
      @record.total_lufeb_media =
        medien_grundlagen.to_i +
        website.to_i +
        newsletter.to_i +
        videos.to_i +
        social_media.to_i +
        beratungsmodule.to_i +
        apps.to_i
    end

  end
end

