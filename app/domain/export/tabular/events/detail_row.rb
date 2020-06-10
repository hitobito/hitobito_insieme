# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export::Tabular::Events
  class DetailRow < Export::Tabular::Events::Row
    include Vertragsperioden::Domain

    delegate :year, to: :entry

    def initialize(*args)
      super
      self.class.delegate(*vp_class('Export::Tabular::Events::DetailList')::COURSE_RECORD_ATTRS,
                          to: :course_record, allow_nil: true)
    end

  end
end
