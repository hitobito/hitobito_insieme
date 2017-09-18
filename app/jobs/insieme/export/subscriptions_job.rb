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
