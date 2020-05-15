# frozen_string_literal: true

#  Copyright (c) 2020, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020
  class TimeRecord::Calculation

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

             to: :record

    def total_lufeb
      total_lufeb_general.to_i +
        total_lufeb_private.to_i +
        total_lufeb_specific.to_i +
        total_lufeb_promoting.to_i
    end

    def total_courses
      blockkurse.to_i +
        tageskurse.to_i +
        jahreskurse.to_i
    end

    def total_additional_person_specific
      treffpunkte.to_i +
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
      calculate_total_lufeb_general
      calculate_total_lufeb_private
      calculate_total_lufeb_specific
      calculate_total_lufeb_promoting
    end

    private

    def bsv_hours_per_year
      globals ? globals.bsv_hours_per_year : DEFAULT_BSV_HOURS_PER_YEAR
    end

    def globals
      @globals ||= ReportingParameter.for(year)
    end

    # rubocop:disable MethodLength, Metrics/AbcSize
    def calculate_total_lufeb_general
      @record.total_lufeb_general =
        kontakte_medien.to_i +
        interviews.to_i +
        publikationen.to_i +
        referate.to_i +
        medienkonferenzen.to_i +
        informationsveranstaltungen.to_i +
        sensibilisierungskampagnen.to_i +
        allgemeine_auskunftserteilung.to_i +
        kontakte_meinungsbildner.to_i +
        beratung_medien.to_i
    end
    # rubocop:enable MethodLength, Metrics/AbcSize

    def calculate_total_lufeb_private
      @record.total_lufeb_private =
        eigene_zeitschriften.to_i +
        newsletter.to_i +
        informationsbroschueren.to_i +
        eigene_webseite.to_i
    end

    def calculate_total_lufeb_specific
      @record.total_lufeb_specific =
        erarbeitung_instrumente.to_i +
        erarbeitung_grundlagen.to_i +
        projekte.to_i +
        vernehmlassungen.to_i +
        gremien.to_i
    end

    # rubocop:disable Metrics/AbcSize
    def calculate_total_lufeb_promoting
      @record.total_lufeb_promoting =
        auskunftserteilung.to_i +
        vermittlung_kontakte.to_i +
        unterstuetzung_selbsthilfeorganisationen.to_i +
        koordination_selbsthilfe.to_i +
        treffen_meinungsaustausch.to_i +
        beratung_fachhilfeorganisationen.to_i +
        unterstuetzung_behindertenhilfe.to_i
    end
    # rubocop:enable Metrics/AbcSize

  end
end

