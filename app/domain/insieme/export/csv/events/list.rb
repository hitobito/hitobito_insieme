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
      build_attribute_labels_without_insieme
        .merge(additional_course_labels)
        .merge(course_record_labels)
        .merge(count_labels)
    end

    def additional_course_labels
      [:motto, :cost, :application_opening_at, :application_closing_at,
       :maximum_participants, :external_applications, :priorization,
       :leistungskategorie].each_with_object({}) do |attr, labels|
        labels[attr] = ::Event.human_attribute_name(attr)
      end
    end

    def course_record_labels
      [:subventioniert, :inputkriterien, :kursart,
       :spezielle_unterkunft].each_with_object({}) do |attr, labels|
        labels[attr] = ::Event::CourseRecord.human_attribute_name(attr)
      end
    end

    def count_labels
      [:participations_all_count, :participations_teamers_count,
       :participations_participants_count].each_with_object({}) do |attr, labels|
        labels[attr] = ::Event.human_attribute_name(attr)
      end
    end
  end
end
