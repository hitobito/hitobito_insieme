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

      alias_method_chain :render_xlsx, :details
    end

    private

    def build_course_record
      if entry.reportable?
        entry.build_course_record
        entry.course_record.set_defaults
      end
    end

    def render_xlsx_with_details(entries)
      title = t('export/xlsx/events.title')
      send_data(xlsx_exporter.export(entries, group.name, year, title), type: :xlsx, filename: xlsx_filename)
    end

    def xlsx_exporter
      if course_records? && can?(:export_course_records, @group)
        ::Export::Xlsx::Events::DetailList
      else
        ::Export::Xlsx::Events::ShortList
      end
    end

    def xlsx_filename
      vid = group.vid.present? ? "_vid#{group.vid}" : ''
      bsv = group.bsv_number.present? ? "_bsv#{group.bsv_number}" : ''
      group_name = group.name.parameterize
      "#{request_event_type}#{vid}#{bsv}_#{group_name}_#{year}.xlsx"
    end

    def course_records?
      entries.first.respond_to?(:course_record)
    end

    def request_event_type
      request.path.split('/').last.split('.').first
    end

  end
end
