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
      @tempfile_name = filename
    end

    def can?(action, object)
      Ability.new(::Person.find(@user_id)).can?(action, object)
    end

    def data_with_insieme
      exporter_class.export(@format, entries, group_name, @year)
    end

    def exporter_class
      list_type = 'ShortList'

      if can?(:export_course_records, @parent) && course_records?
        list_type = 'DetailList'
      end

      list_type = "AggregateCourse::#{list_type}" if aggregate_course?
      "::Export::Tabular::Events::#{list_type}".constantize
    end

    def filename
      vid = @parent.vid.present? ? "_vid#{@parent.vid}" : ''
      bsv = @parent.bsv_number.present? ? "_bsv#{@parent.bsv_number}" : ''
      "#{filename_prefix}#{vid}#{bsv}_#{group_name}_#{@year}.#{@format}"
    end

    def aggregate_course?
      @event_type == ::Event::AggregateCourse.sti_name
    end

    def group_name
      @parent.name.parameterize
    end

    def filename_prefix
      @event_type.to_s.demodulize.underscore || 'simple'
    end

    def course_records?
      entries.first.respond_to?(:course_record)
    end

  end

end
