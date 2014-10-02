# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module EventsController
    extend ActiveSupport::Concern

    COURSE_RECORD_ATTRIBUTES = [:id, :subventioniert, :inputkriterien,
                                :spezielle_unterkunft, :kursart]


    included do
      before_render_form :build_course_record, if: :new_course?

      self.permitted_attrs += [course_record_attributes: COURSE_RECORD_ATTRIBUTES]
    end

    private

    def build_course_record
      entry.build_course_record
      entry.course_record.set_defaults
    end

    def new_course?
      entry.is_a?(Event::Course) && entry.new_record?
    end

  end
end
