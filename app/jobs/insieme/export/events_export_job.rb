# encoding: utf-8

#  Copyright (c) 2017, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Export::EventsExportJob
    extend ActiveSupport::Concern

    included do
      alias_method_chain :data, :insieme
    end

    def initialize_with_insieme(*args)
      initialize_without_insieme(*args)
    end

    def data_with_insieme
      year = filter.year
      group_name = filter.group.name.parameterize

      exporter_class.export(@format, entries, group_name, year)
    end

    def exporter_class
      list_type = 'ShortList'

      if ability.can?(:export_course_records, group) && course_records?
        list_type = 'DetailList'
      end

      list_type = "AggregateCourse::#{list_type}" if aggregate_course?
      "::Export::Tabular::Events::#{list_type}".constantize
    end

    def aggregate_course?
      filter.type == ::Event::AggregateCourse.sti_name
    end

    def course_records?
      entries.first.respond_to?(:course_record)
    end

  end

end
