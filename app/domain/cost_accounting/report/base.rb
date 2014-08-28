module CostAccounting
  module Report
    class Base
      FIELDS =  %w(kontengruppe
                   aufwand_ertrag_fibu
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

      class_attribute :used_fields
      self.used_fields = []

      class_attribute :kontengruppe

      class_attribute :editable

      attr_reader :table

      class << self
        def key
          name.demodulize.underscore
        end
      end

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

    end
  end
end