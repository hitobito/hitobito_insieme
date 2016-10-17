# encoding: utf-8

#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export::Csv::Events
  class DetailRow < Export::Csv::Events::Row

    delegate(*DetailList::COURSE_RECORD_ATTRS, to: :course_record, allow_nil: true)

  end
end
