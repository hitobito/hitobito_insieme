# frozen_string_literal: true

#  Copyright (c) 2020-2022, Insieme Schweiz. This file is part of hitobito_insieme
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
      featureperiode.domain_class(class_name).tap do |fp_class_name|
        Rails.logger.debug "FP: Domain class #{fp_class_name}"
      end
    end

    def fp_i18n_scope(controller_name)
      featureperiode.i18n_scope(controller_name).tap do |fp_i18n_scope|
        Rails.logger.debug "FP: I18n-scope #{fp_i18n_scope}"
      end
    end
  end
end
