# frozen_string_literal: true
#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module EventsController
    def self.prepended(base)
      base.send :include, Vertragsperioden::Views

      base.before_render_new :build_course_record

      base.permitted_attrs += [
        course_record_attributes: [:id, :anzahl_kurse, :subventioniert, :inputkriterien,
                                   :spezielle_unterkunft, :kursart]
      ]
    end

    def render_tabular_in_background(format)
      super(format, custom_filename)
    end

    private

    def build_course_record
      if entry.reportable?
        entry.build_course_record
        entry.course_record.set_defaults
      end
    end

    def model_params
      super.tap do |p|
        p[:course_record_attributes] ||= {} if action_name == 'create'
      end
    end

    def custom_filename
      ::Export::Event::Filename.new(group, event_filter.type, event_filter.year).to_s
    end

  end
end
