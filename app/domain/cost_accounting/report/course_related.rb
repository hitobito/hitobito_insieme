# encoding: utf-8

#  Copyright (c) 2012-2016, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CostAccounting
  module Report
    class CourseRelated < Base

      COURSE_FIELDS = { blockkurse: 'bk',
                        tageskurse: 'tk',
                        jahreskurse: 'sk' }

      COURSE_FIELDS.each do |field, lk|
        define_method(field) do
          table.course_costs(key, lk).try(:to_d)
        end
      end

    end
  end
end
