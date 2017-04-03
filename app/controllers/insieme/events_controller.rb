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

      self.permitted_attrs += [
        course_record_attributes: [:id, :anzahl_kurse, :subventioniert, :inputkriterien,
                                   :spezielle_unterkunft, :kursart]
      ]

      alias_method_chain :render_tabular, :details
    end

    private

    def build_course_record
      if entry.reportable?
        entry.build_course_record
        entry.course_record.set_defaults
      end
    end

    def render_tabular_with_details(format, entries)
      send_data(tabular_exporter.export(format, entries, group.name, year),
                type: format,
                filename: tabular_filename(format))
    end

    def tabular_exporter
      list_type = 'ShortList'

      if can?(:export_course_records, @group) && course_records?
        list_type = 'DetailList'
      end

      list_type = "AggregateCourse::#{list_type}" if aggregate_course?
      "::Export::Tabular::Events::#{list_type}".constantize
    end

    def tabular_filename(format)
      vid = group.vid.present? ? "_vid#{group.vid}" : ''
      bsv = group.bsv_number.present? ? "_bsv#{group.bsv_number}" : ''
      group_name = group.name.parameterize
      "#{request_event_type}#{vid}#{bsv}_#{group_name}_#{year}.#{format}"
    end

    def aggregate_course?
      request_event_type == 'aggregate_course'
    end

    def course_records?
      entries.first.respond_to?(:course_record)
    end

    def request_event_type
      request.path.split('/').last.split('.').first
    end

  end
end
