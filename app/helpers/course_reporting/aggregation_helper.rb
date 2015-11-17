# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CourseReporting::AggregationHelper

  def course_aggregation_csv_button(attrs)
    attrs = { categories: [1, 2, 3], subsidized: true, format: :csv }.merge(attrs)
    key = [attrs[:subsidized] ? :subsidized : :unsubsidized, Array(attrs[:categories])]
    action_button(t("course_reporting.aggregations.index.#{key.join('_')}"),
                  aggregation_export_group_path(attrs))
  end

end
