# encoding: utf-8
#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/insieme_insieme.

Fabricator(:aggregate_course, from: :event, class_name: :'Event::AggregateCourse') do
  groups { [Group.all_types.detect { |t| t.event_types.include?(Event::AggregateCourse) }.first] }
end
