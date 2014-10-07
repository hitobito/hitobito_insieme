# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module EventsController
    extend ActiveSupport::Concern

    included do
      before_render_new :build_course_record

      self.permitted_attrs += [course_record_attributes: [:id, :subventioniert, :inputkriterien,
                                                          :spezielle_unterkunft, :kursart]]
    end

    private

    def build_course_record
      if entry.is_a?(Event::Course)
        entry.build_course_record
        entry.course_record.set_defaults
      end
    end

  end
end
