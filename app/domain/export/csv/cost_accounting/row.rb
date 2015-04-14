# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export::Csv::CostAccounting
  class Row < Export::Csv::Row

    def report
      entry.class.human_name
    end

    private

    def value_for(attr)
      if entry.respond_to?(attr, true)
        entry.send(attr)
      else
        super
      end
    end

  end
end
