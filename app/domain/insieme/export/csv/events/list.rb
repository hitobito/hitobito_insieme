# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Export::Csv::Events
  module List
    extend ActiveSupport::Concern

    included do
      alias_method_chain :build_attribute_labels, :insieme
    end

    def build_attribute_labels_with_insieme
      build_attribute_labels_without_insieme.tap do |labels|
        if model_class <= Event::Reportable
          add_insieme_course_labels(labels)
          add_course_record_labels(labels)
        end
      end
    end

    private

    def add_insieme_course_labels(labels)
      labels[:leistungskategorie] = human_attribute(:leistungskategorie)
    end

    def add_course_record_labels(labels)
      [:subventioniert, :inputkriterien, :kursart, :spezielle_unterkunft, :anzahl_kurse].
      each do |attr|
        labels[attr] = ::Event::CourseRecord.human_attribute_name(attr)
      end
    end
  end
end
