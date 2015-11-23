# encoding: utf-8

#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Export::Csv::Events
  class DetailList < Export::Csv::Events::List
    ADD_COURSE_RECORD_ATTRS = [:teilnehmende_behinderte, :teilnehmende_mehrfachbehinderte,
                               :teilnehmende_angehoerige, :teilnehmende_weitere,
                               :leiterinnen, :fachpersonen,
                               :hilfspersonal_ohne_honorar, :hilfspersonal_mit_honorar,
                               :kuechenpersonal, :honorare_inkl_sozialversicherung,
                               :unterkunft, :uebriges,
                               :beitraege_teilnehmende, :direkter_aufwand,
                               :gemeinkostenanteil, :zugeteilte_kategorie,
                               :tage_behinderte, :tage_angehoerige, :tage_weitere]

    self.row_class = Export::Csv::Events::DetailRow

    private
    def build_attribute_labels
      super.tap do |labels|
        add_additional_course_record_labels(labels)
      end
    end

    def add_additional_course_record_labels(labels)
      ADD_COURSE_RECORD_ATTRS.each do |attr|
        add_course_record_label(labels, attr)
      end
    end


  end
end
