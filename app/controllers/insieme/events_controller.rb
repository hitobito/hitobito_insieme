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
        send_data ::Export::Csv::Events::DetailList.export(entries), type: :csv
      else
        render_csv_without_details(entries)
      end
    end

    def course_records?
      entries.first.respond_to?(:course_record)
    end
  end
end
