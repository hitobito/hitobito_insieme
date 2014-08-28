# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module CostAccounting
  module Report
    class Base

      FIELDS =  %w(aufwand_ertrag_fibu
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
                   kontrolle)

      # The fields displayed in the detail view of the report.
      class_attribute :used_fields
      # Most commonly used fields, override in subclasses
      self.used_fields = %w(aufwand_ertrag_fibu
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
                            kontrolle)

      # The editable fields of this report.
      class_attribute :editable_fields
      self.editable_fields = []

      # The kind of the report, e.g. subtotal, total.
      class_attribute :kind

      # The kontengruppe of this report.
      class_attribute :kontengruppe

      class << self
        def key
          name.demodulize.underscore
        end

        def human_name
          I18n.t("cost_accounting.report.#{key}.name")
        end

        def set_editable_fields(fields)
          self.editable_fields = fields
          delegate *fields, to: :record
        end

        def editable?
          editable_fields.present?
        end
      end

      attr_reader :table

      delegate :key, :human_name, :editable?, to: :class

      def initialize(table)
        @table = table
      end

      # define accessor methods for all fields, returning nil
      FIELDS.each do |f|
        define_method(f) {}
      end

      def aufwand_ertrag_ko_re
        @aufwand_ertrag_ko_re ||= begin
          aufwand_ertrag_fibu.to_d -
          abgrenzung_fibu.to_d -
          abgrenzung_dachorganisation.to_d
        end
      end

      def total
        @total ||= begin
          verwaltung.to_d +
          beratung.to_d +
          treffpunkte.to_d +
          blockkurse.to_d +
          tageskurse.to_d +
          jahreskurse.to_d +
          lufeb.to_d +
          mittelbeschaffung.to_d
        end
      end

      def kontrolle
        total - aufwand_ertrag_ko_re
      end

      def record
        @record ||= table.cost_record(key)
      end

    end
  end
end