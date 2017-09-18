# encoding: utf-8

#  Copyright (c) 2017, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Export::SubscriptionsJob

    extend ActiveSupport::Concern

    included do
      alias_method_chain :data, :insieme
    end

    def data_with_insieme
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
