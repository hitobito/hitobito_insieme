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
      alias_method_chain :initialize, :insieme
    end

    def initialize_with_insieme(*args)
      initialize_without_insieme(*args)
    end

    def data_with_insieme
      exporter_class.export(@format, entries, group_name, year)
    end

    def exporter_class
      list_type = 'ShortList'

      if ability.can?(:export_course_records, parent) && course_records?
        list_type = 'DetailList'
      end

      list_type = "AggregateCourse::#{list_type}" if aggregate_course?
      "::Export::Tabular::Events::#{list_type}".constantize
    end

    def aggregate_course?
      type == ::Event::AggregateCourse.sti_name
    end

    def group_name
      parent.name.parameterize
    end

    def course_records?
      entries.first.respond_to?(:course_record)
    end

    def parent
      @filter.group
    end

    def year
      @filter.year
    end

    def type
      @filter.type
    end

  end

end
