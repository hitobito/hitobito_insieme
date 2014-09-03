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
                               :edit_group_event_course_record_path,
                               if: lambda do |view, group, event|
                                 report_groups = [Group::Dachverein, Group::Regionalverein]
                                 valid_group = report_groups.any? do |c|
                                   group.is_a?(c) && view.can?(:reporting, group)
                                 end

                                 valid_event = event.type == Event::Course.sti_name
                                 # TODO: ensure that event is "blockkurs" and maybe also if
                                 #       it is terminated

                                 valid_group && valid_event
                               end))
  end

end
