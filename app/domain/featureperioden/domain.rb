# frozen_string_literal: true

#  Copyright (c) 2020, Insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Featureperioden
  module Domain
    def featureperiode
      @featureperiode ||= begin
                             raise Featureperioden::NoYearError if year.blank?

                             Featureperioden::Dispatcher.new(year)
                           end
    end

    def fp_class(class_name)
      featureperiode.domain_class(class_name)
    end

    def fp_i18n_scope(controller_name)
      featureperiode.i18n_scope(controller_name)
    end
  end
end
