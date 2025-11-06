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

    # Resolve the given constant path, e.g. "CourseReporting::ClientStatistics" in the newest FP <= target year,
    # falling back to older FPs, if it doesn't exist in the newest.
    # - Skips/logs missing FP modules (e.g., Fp2024 not yet defined).
    # - Walks constants without ancestor lookup (const_defined?(..., false)).
    # - Raises with a clear chain if nothing is found.
    def fp_class(class_name)
      target_year = featureperiode.determine

      namespaces = Featureperioden::Dispatcher::KNOWN_BASE_YEARS
        .select { |y| y <= target_year }   # backwards only
        .sort.reverse                      # newest → oldest
        .map { |y| Object.const_get("Fp#{y}") }

      parts = class_name.split("::")

      namespaces.each do |ns|
        context_namespace = ns
        ok = true

        parts.each do |name|
          if context_namespace.const_defined?(name, false)
            context_namespace = context_namespace.const_get(name)
          else
            ok = false
            break
          end
        end

        return context_namespace if ok
      end

      raise NameError, "Class #{class_name} not found in FP chain: #{namespaces.map(&:name).join(" → ")}"
    end

    def fp_i18n_scope(controller_name)
      featureperiode.i18n_scope(controller_name).tap do |fp_i18n_scope|
        Rails.logger.debug "FP: I18n-scope #{fp_i18n_scope}"
      end
    end
  end
end
