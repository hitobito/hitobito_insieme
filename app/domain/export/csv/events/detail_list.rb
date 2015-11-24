# encoding: utf-8

#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Export::Csv::Events
  class DetailList < Export::Csv::Events::List
    COURSE_RECORD_ATTRS = [
                 :kursdauer,
                 ## effektiv teilnehmende
                 :teilnehmende_behinderte, :teilnehmende_mehrfachbehinderte,
                 :teilnehmende_angehoerige, :teilnehmende_weitere,
                 ## absenztage
                 :absenzen_behinderte, :absenzen_angehoerige, :absenzen_weitere,
                 ## total teilnehmerinnentage
                 :tage_behinderte, :tage_angehoerige, :tage_weitere,
                 ## betreuerinnen
                 :leiterinnen, :fachpersonen,
                 :hilfspersonal_mit_honorar, :hilfspersonal_ohne_honorar,
                 ## personal ohne betreuungsfunktion
                 :kuechenpersonal,
                 ## direkter aufwand
                 :honorare_inkl_sozialversicherung, :unterkunft, :uebriges,
                 :direkter_aufwand,
                 # ertrag
                 :beitraege_teilnehmende, 
                 # auswertungen
                 :gemeinkostenanteil, :total_vollkosten,
                 :total_tage_teilnehmende, :vollkosten_pro_le, 
                 :zugeteilte_kategorie ]

    self.row_class = Export::Csv::Events::DetailRow

    private
    def build_attribute_labels
      super.tap do |labels|
        add_additional_course_record_labels(labels)
      end
    end

    def add_additional_course_record_labels(labels)
      COURSE_RECORD_ATTRS.each do |attr|
        add_course_record_label(labels, attr)
      end
    end

  end
end
