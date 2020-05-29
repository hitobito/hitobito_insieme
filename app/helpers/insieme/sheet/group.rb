# frozen_string_literal: true
#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Sheet::Group
  extend ActiveSupport::Concern

  included do
    tabs.insert(4,
                Sheet::Tab.new('activerecord.models.event/aggregate_course.other',
                               :aggregate_course_group_events_path,
                               params: { returning: true },
                               if: lambda do |view, group|
                                 group.event_types.include?(::Event::AggregateCourse) &&
                                   view.can?(:'index_event/aggregate_courses', group)
                               end))

    tabs.insert(-2,
                Sheet::Tab.new('statistics.title',
                               :statistics_group_path,
                               if: :statistics))

    tabs.insert(-2,
                Sheet::Tab.new('reporting.title',
                               :cost_accounting_group_path,
                               alt: [:base_time_record_group_path],
                               params: { returning: true },
                               if: :reporting))

    tabs.insert(-2,
                Sheet::Tab.new('controlling.title',
                               :controlling_group_path,
                               params: { returning: true },
                               if: :controlling))
  end

end
