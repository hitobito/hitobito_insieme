# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module SubscriptionsController
    extend ActiveSupport::Concern

    included do
      alias_method_chain :render_csv, :insieme
      alias_method_chain :index, :insieme
    end


    def index_with_insieme
      respond_to do |format|
        format.html  { load_grouped_subscriptions }
        format.pdf   { render_pdf(mailing_list.people) }
        format.csv   { render_csv(mailing_list.people(::Person)) }
        format.email { render_emails(mailing_list.people) }
      end
    end

    private


    class SubscriptionsAddress < ::Export::Csv::People::PeopleAddress
      def additional_person_attributes
        super + [:language, :salutation, :canton, :additional_information]
      end
    end

    def render_csv_with_insieme(people)
      send_data SubscriptionsAddress.export(people), type: :csv
    end

  end
end
