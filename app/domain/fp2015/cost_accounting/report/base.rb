# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2015::CostAccounting
  module Report
    class Base
      FIELDS = %w[aufwand_ertrag_fibu
        abgrenzung_fibu
        abgrenzung_dachorganisation
        aufwand_ertrag_ko_re

        personal
        raeumlichkeiten
        verwaltung
        beratung
        treffpunkte
        blockkurse
        tageskurse
        jahreskurse
        lufeb
        mittelbeschaffung
        total
        kontrolle]

      # The fields displayed in the detail view of the report.
      class_attribute :used_fields
      # Most commonly used fields, override in subclasses
      self.used_fields = %w[aufwand_ertrag_fibu
        abgrenzung_fibu
        abgrenzung_dachorganisation
        aufwand_ertrag_ko_re

        beratung
        treffpunkte
        blockkurse
        tageskurse
        jahreskurse
        lufeb
        mittelbeschaffung
        total
        kontrolle]

      # The editable fields of this report.
      class_attribute :editable_fields
      self.editable_fields = []

      # The kind of the report, e.g. subtotal, total.
      class_attribute :kind

      # The kontengruppe of this report.
      class_attribute :kontengruppe

      # Whether this report counts as aufwand or ertrag
      class_attribute :aufwand
      self.aufwand = true

      class << self
        def key
          name.demodulize.underscore
        end

        def short_name(year)
          scope = Featureperioden::Dispatcher.new(year).i18n_scope("cost_accounting")
          I18n.t("report.#{key}.short_name", scope: scope,
            default: I18n.t("cost_accounting.report.#{key}.short_name"))
        end

        def human_name(year)
          scope = Featureperioden::Dispatcher.new(year).i18n_scope("cost_accounting")
          I18n.t("report.#{key}.name", scope: scope,
            default: I18n.t("cost_accounting.report.#{key}.name"))
        end

        def delegate_editable_fields(fields)
          self.editable_fields = fields
          delegate(*fields, to: :record)
        end

        def editable?
          editable_fields.present?
        end
      end

      attr_reader :table

      delegate :key, :editable?, to: :class
      delegate :year, to: :table

      def initialize(table)
        @table = table
      end

      # define accessor methods for all fields, returning nil
      FIELDS.each do |f|
        define_method(f) {}
      end

      def short_name
        self.class.short_name(year)
      end

      def human_name
        self.class.human_name(year)
      end

      def aufwand_ertrag_ko_re
        @aufwand_ertrag_ko_re ||= aufwand_ertrag_fibu.to_d -
          abgrenzung_fibu.to_d -
          abgrenzung_dachorganisation.to_d
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def total
        @total ||= raeumlichkeiten.to_d +
          verwaltung.to_d +
          beratung.to_d +
          treffpunkte.to_d +
          blockkurse.to_d +
          tageskurse.to_d +
          jahreskurse.to_d +
          lufeb.to_d +
          mittelbeschaffung.to_d
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def kontrolle
        total - aufwand_ertrag_ko_re
      end

      def record
        @record ||= table.cost_record(key)
      end
    end
  end
end
