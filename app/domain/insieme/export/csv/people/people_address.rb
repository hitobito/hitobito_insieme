# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Export
    module Csv
      module People
        module PeopleAddress
          extend ActiveSupport::Concern

          included do
            alias_method_chain :person_attributes, :name
          end

          def person_attributes_with_name
            person_attributes_without_name + [:name]
          end
        end
      end
    end
  end
end
