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

      alias_method_chain :index, :csv
    end

    def index_with_csv
      respond_to do |format|
        format.html  { entries }
        format.csv   { render_csv_entries(entries) if can?(:export_group_courses, Event) }
      end
    end

    private

    def build_course_record
      if entry.is_a?(Event::Course)
        entry.build_course_record
        entry.course_record.set_defaults
      end
    end

    def prepare_csv_entries(entries)
      entries.includes(:course_record)
    end

    def render_csv_entries(entries)
      render_csv(prepare_csv_entries(entries))
    end

    def render_csv(entries)
      send_data ::Export::Csv::Events::List.export(entries), type: :csv
    end
  end
end
