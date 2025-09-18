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
      target_year = featureperiode.determine
      namespaces = Featureperioden::Dispatcher::KNOWN_BASE_YEARS
                    .select { |y| y <= target_year }
                    .sort.reverse
                    .map { |y| Object.const_get("FP#{y}") }
      
      parts = class_name.split("::")
      namespaces.each do |ns|
        ctx = ns
        ok = parts.all? do |name|
          return false unless ctx.const_defined?(name, false)
          ctx = ctx.const_get(name)
          true
        end
        return ctx if ok
      end

      raise NameError, "Class #{class_name} not found in FP chain: #{namespaces.mpa(&:name).join(' → ')}"
    end

    def fp_i18n_scope(controller_name)
      featureperiode.i18n_scope(controller_name).tap do |fp_i18n_scope|
        Rails.logger.debug "FP: I18n-scope #{fp_i18n_scope}"
      end
    end
  end
end
