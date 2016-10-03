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
                                   :spezielle_unterkunft, :kursart]]

      alias_method_chain :render_csv, :details
    end

    private

    def build_course_record
      if entry.reportable?
        entry.build_course_record
        entry.course_record.set_defaults
      end
    end

    def render_csv_with_details(entries)
      if course_records? && can?(:export_course_records, @group)
        course_list = ::Export::Csv::Events::DetailList.export(entries)
      else
        course_list = ::Export::Csv::Events::List.export(entries)
      end
      send_data course_list, type: :csv, filename: filename
    end

    def filename
      type = aggregate_course? ? 'aggregate_course' : 'course'
      group_name = group.name.parameterize
      vid = group.vid.present? && "_vid#{group.vid}" || ''
      bsv = group.bsv_number.present? && "_bsv#{group.bsv_number}" || ''
      "#{type}#{vid}#{bsv}_#{group_name}_#{year}.csv"
    end

    def aggregate_course?
      params[:type] == 'Event::AggregateCourse'
    end

    def course_records?
      entries.first.respond_to?(:course_record)
    end
  end
end
