# frozen_string_literal: true

#  Copyright (c) 2020, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2015
  class Event::CourseRecord::Calculation

    attr_reader :record

    def initialize(record)
      @record = record
    end

    # rubocop:disable Layout/EmptyLinesAroundArguments
    delegate :inputkriterien,
             :subventioniert,
             :kursart,
             :kursdauer,
             :teilnehmende_behinderte,
             :teilnehmende_angehoerige,
             :teilnehmende_weitere,
             :absenzen_behinderte,
             :absenzen_angehoerige,
             :absenzen_weitere,
             :leiterinnen,
             :fachpersonen,
             :hilfspersonal_ohne_honorar,
             :hilfspersonal_mit_honorar,
             :kuechenpersonal,
             :honorare_inkl_sozialversicherung,
             :unterkunft,
             :uebriges,
             :beitraege_teilnehmende,
             :spezielle_unterkunft,
             :year,
             :teilnehmende_mehrfachbehinderte,
             :direkter_aufwand,
             :gemeinkostenanteil,
             :gemeinkosten_updated_at,
             :zugeteilte_kategorie,
             :challenged_canton_count_id,
             :affiliated_canton_count_id,
             :anzahl_kurse,
             :tage_behinderte,
             :tage_angehoerige,
             :tage_weitere,
             :betreuerinnen,

             :event,
             :challenged_canton_count,
             :affiliated_canton_count,

             :anzahl_spezielle_unterkunft,

             :event,
             to: :record
    # rubocop:enable Layout/EmptyLinesAroundArguments

    ::Event::Reportable::LEISTUNGSKATEGORIEN.each do |kategorie|
      delegate :"#{kategorie}?", to: :record
    end

    def total_absenzen
      absenzen_behinderte.to_d +
          absenzen_angehoerige.to_d +
          absenzen_weitere.to_d
    end

    def teilnehmende
      teilnehmende_behinderte.to_i +
          teilnehmende_angehoerige.to_i +
          teilnehmende_weitere.to_i
    end

    def betreuende
      if tp?
        betreuerinnen.to_i
      else
        leiterinnen.to_i +
            fachpersonen.to_i +
            hilfspersonal_mit_honorar.to_i +
            hilfspersonal_ohne_honorar.to_i
      end
    end

    def total_tage_teilnehmende
      tage_behinderte.to_d +
          tage_angehoerige.to_d +
          tage_weitere.to_d
    end

    def total_stunden_betreuung
      betreuende * kursdauer.to_d
    end

    def praesenz_prozent
      if total_tage_teilnehmende.positive?
        ((total_tage_teilnehmende / (total_tage_teilnehmende + total_absenzen)) * 100).round
      else
        100
      end
    end

    def betreuungsschluessel
      if betreuende.to_d.positive?
        teilnehmende_behinderte.to_d / betreuende.to_d
      else
        0
      end
    end

    def total_vollkosten
      direkter_aufwand.to_d +
          gemeinkostenanteil.to_d
    end

    def direkte_kosten_pro_le
      if total_tage_teilnehmende.positive?
        direkter_aufwand.to_d / total_tage_teilnehmende
      else
        0
      end
    end

    def vollkosten_pro_le
      if total_tage_teilnehmende.positive?
        total_vollkosten / total_tage_teilnehmende
      else
        0
      end
    end

    def duration_in_days?
      !duration_in_hours?
    end

    def duration_in_hours?
      sk? || tp?
    end

    def set_cached_values
      @record.teilnehmende_behinderte = challenged_canton_count&.total
      @record.teilnehmende_angehoerige = affiliated_canton_count&.total
      @record.direkter_aufwand = calculate_direkter_aufwand
      unless event.is_a?(::Event::AggregateCourse)
        @record.tage_behinderte = calculate_tage_behinderte
        @record.tage_angehoerige = calculate_tage_angehoerige
        @record.tage_weitere = calculate_tage_weitere
      end
    end

    private

    def calculate_direkter_aufwand
      honorare_inkl_sozialversicherung.to_d +
          unterkunft.to_d +
          uebriges.to_d
    end

    def calculate_tage_behinderte
      (kursdauer.to_d * teilnehmende_behinderte.to_i) - absenzen_behinderte.to_d
    end

    def calculate_tage_angehoerige
      (kursdauer.to_d * teilnehmende_angehoerige.to_i) - absenzen_angehoerige.to_d
    end

    def calculate_tage_weitere
      (kursdauer.to_d * teilnehmende_weitere.to_i) - absenzen_weitere.to_d
    end

  end
end
