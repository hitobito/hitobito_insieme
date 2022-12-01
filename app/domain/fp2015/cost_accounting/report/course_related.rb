# frozen_string_literal: true

#  Copyright (c) 2012-2016, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2015::CostAccounting
  module Report
    class CourseRelated < Base

      # Only calculate course values from this year on.
      # For years before, use the values stored in the database.
      AUTOMATE_FROM_YEAR = 2016

      COURSE_FIELDS = { blockkurse: 'bk',
                        tageskurse: 'tk',
                        jahreskurse: 'sk' }

      COURSE_FIELDS.each do |field, lk|
        define_method(field) do
          if record.year >= AUTOMATE_FROM_YEAR
            table.course_costs(key, lk).try(:to_d)
          else
            record.send(field)
          end
        end
      end

    end
  end
end
