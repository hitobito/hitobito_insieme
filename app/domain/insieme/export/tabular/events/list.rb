# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Export::Tabular::Events
  module List

    def build_attribute_labels
      super.tap do |labels|
        if model_class <= Event::Reportable
          add_insieme_course_labels(labels)
          add_course_record_labels(labels)
        end
      end
    end

    private

    def add_insieme_course_labels(labels)
      labels[:leistungskategorie] = human_attribute(:leistungskategorie)
      labels[:fachkonzept] = human_attribute(:fachkonzept)
    end

    def add_course_record_labels(labels)
      [
        :year, :subventioniert, :inputkriterien, :kursart, :spezielle_unterkunft, :anzahl_kurse
      ].each do |attr|
        add_course_record_label(labels, attr)
      end
    end

    def add_course_record_label(labels, attr)
      label = translate(attr.to_s, default: ::Event::CourseRecord.human_attribute_name(attr))
      labels[attr] = label
    end

    def remove_course_record_label(labels, attr)
      labels.except! attr
    end

  end
end
