# frozen_string_literal: true

#  Copyright (c) 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2020::CostAccounting
  module Report
    class CourseRelated < Base

      COURSE_FIELDS = { blockkurse: 'bk',
                        tageskurse: 'tk',
                        jahreskurse: 'sk',
                        treffpunkte: 'tp' }.freeze

      COURSE_FIELDS.each do |field, lk|
        define_method(field) do
          table.course_costs(key, lk).try(:to_d)
        end
      end

    end
  end
end
