# frozen_string_literal: true

#  Copyright (c) 2020, Insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vertragsperioden
  module Domain
    def vertragsperiode
      @vertragsperiode ||= begin
                             raise Vertragsperioden::NoYearError unless year.present?
                             Vertragsperioden::Dispatcher.new(year)
                           end
    end

    def vp_class(class_name)
      vertragsperiode.domain_module(class_name)
    end
  end
end
