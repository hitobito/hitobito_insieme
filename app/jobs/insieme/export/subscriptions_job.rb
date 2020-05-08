# encoding: utf-8

#  Copyright (c) 2017-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Export::SubscriptionsJob
    def data
      ::Export::Tabular::People::SubscriptionsAddress.export(
        @format,
        mailing_list.people(::Person.select('people.*'))
                    .order_by_name
                    .preload_public_accounts
                    .includes(roles: :group)
      )
    end
  end
end
