# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Export::Tabular::People
  class SubscriptionsAddress < ::Export::Tabular::People::PeopleAddress
    def additional_person_attributes
      super + [:language, :salutation, :canton, :additional_information]
    end
  end
end
