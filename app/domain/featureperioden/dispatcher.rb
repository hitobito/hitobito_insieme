# frozen_string_literal: true

#  Copyright (c) 2020-2022, Insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later. See
#  the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Featureperioden
  class Dispatcher
    # Start years of all supported Featureperioden (FPs).
    KNOWN_BASE_YEARS = [2015, 2020, 2022, 2024].freeze

    # Enumerate the given constant path (e.g. "Export::Xlsx::CostAccounting::Style")
    # across all known FP namespaces (Fp2015, Fp2020, …). Returns an array of the
    # constants that exist; missing ones are skipped (and logged).
    #
    # Used at boot in wagon.rb to pre-register XLSX styles for tabular exports.
    # Missing classes in newer FPs are expected with the fallback approach (see
    # VERTRAGSPERIODEN.md for more information).
    def self.domain_classes(class_name)
      parts = class_name.split("::")

      KNOWN_BASE_YEARS.filter_map do |fp|
        # Resolve the FP namespace (e.g. Object::Fp2024). If the newest FP
        # doesn’t exist yet, log once to avoid noise.
        begin
          ns = Object.const_get("Fp#{fp}")
        rescue NameError
          Rails.logger.debug { "FP skip: Fp#{fp}::#{class_name} not found" } if fp == KNOWN_BASE_YEARS.last
          next
        end

        # Walk the nested constants without falling back to ancestors.
        context_namespace = ns
        ok = parts.all? do |name|
          if context_namespace.const_defined?(name, false)
            context_namespace = context_namespace.const_get(name)
            true
          else
            Rails.logger.debug { "Class skip: Fp#{fp}::#{parts.join("::")} not found" }
            false
          end
        end
        ok ? context_namespace : nil
      end
    end

    def initialize(year)
      @year = year.to_i
    end

    def view_path
      Wagons.find("insieme").root / "app" / "views" / "fp#{determine}"
    end

    def domain_class(class_name)
      "Fp#{determine}::#{class_name}".constantize
    end

    def i18n_scope(scope)
      "fp#{determine}.#{scope}"
    end

    def supported?
      (KNOWN_BASE_YEARS.first..).cover?(@year)
    end

    def determine
      return KNOWN_BASE_YEARS.last if @year >= KNOWN_BASE_YEARS.last # the current period
      return KNOWN_BASE_YEARS.first unless supported? # the earliest year

      KNOWN_BASE_YEARS.each_cons(2) do |period, next_period|
        return period if (period...next_period).cover? @year
      end
    end
  end
end
