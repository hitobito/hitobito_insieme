# encoding: utf-8

#  Copyright (c) 2012-2017, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module SubscriptionsController

    extend ActiveSupport::Concern

    included do
      alias_method_chain :render_tabular, :insieme
    end

    private

    def render_tabular_with_insieme(format, _people)
      people = prepare_tabular_entries(mailing_list.people(::Person).order_by_name)
      send_data ::Export::Tabular::People::SubscriptionsAddress.export(format, people), type: format
    end

  end
end
