# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Sheet::Event
  extend ActiveSupport::Concern

  included do
    tabs.insert(-1,
                Sheet::Tab.new('reporting.title',
                               :group_event_course_record_path,
                               if: lambda do |view, group, event|
                                 event.is_a?(Event::Course) &&
                                 view.can?(:update, Event::CourseRecord.new(event: event))
                               end))
  end

end
