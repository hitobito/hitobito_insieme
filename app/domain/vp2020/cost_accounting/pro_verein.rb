# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020::CostAccounting
  class ProVerein
    include Vertragsperioden::Domain

    attr_reader :year

    def initialize(year)
      @year = year
      @data_for = {}
    end

    def vereine
      @vereine ||= Group.by_bsv_number.all
    end

    def data_for(verein)
      @data_for[verein.id] ||= fetch_data_for(verein)
    end

    CostAccountingRow = Struct.new(
      :aufwand_ertrag_fibu, :abgrenzung, :gemeinkosten, :sozialberatung, :media,
      :jahreskurse, :blockkurse, :tageskurse, :treffpunkte, :lufeb
    ) do
      def self.empty_row
        new(*Array.new(10, nil))
      end

      def members
        [:aufwand_ertrag_fibu, :abgrenzung, :klr, :gemeinkosten, :sozialberatung,
         :bauberatung, :rechtsberatung, :vermittlung, :wohnbegleitung, :media,
         :jahreskurse, :blockkurse, :tageskurse, :treffpunkte, :lufeb]
      end

      def +(other)
        values = to_a.zip(other.to_a).map do |self_value, other_value|
          self_value + other_value
        end

        self.class.new(*values)
      end

      [:klr].each do |empty_col|
        define_method(empty_col) { nil }
      end

      [:bauberatung, :rechtsberatung, :vermittlung, :wohnbegleitung].each do |unused_col|
        define_method(unused_col) { lufeb.nil? ? nil : 0 }
      end
    end

    private

    def report_data(report, table) # rubocop:disable Metrics/MethodLength
      data = ->(value) { table.value_of(report.to_s, value).to_d }

      [
        data['aufwand_ertrag_fibu'],
        data['abgrenzung_fibu'],
        [data['verwaltung'], data['raeumlichkeiten'], data['mittelbeschaffung']].sum,
        data['beratung'],
        data['medien_und_publikationen'],

        data['jahreskurse'],
        data['blockkurse'],
        data['tageskurse'],
        data['treffpunkte'],
        data['lufeb']
      ]
    end

    def fetch_data_for(group) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      table = vp_class('CostAccounting::Table').new(group, year) # Vp2020::CostAccounting::Table

      row                      = ->(report) { CostAccountingRow.new(*report_data(report, table)) }
      empty                    = CostAccountingRow.empty_row
      row_with_method          = ->(method) { CostAccountingRow.new(*send(method, table)) }

      {
        personalaufwand: row_with_method[:personalaufwand],
        honorare: row[:honorare],
        sachaufwand: [row[:raumaufwand], row[:uebriger_sachaufwand]].sum,
        aufwand: empty,
        gemeinkosten: row_with_method[:gemeinkosten],
        umlagen: empty,
        total_aufwand: empty,
        leistungen: row[:leistungsertrag],
        beitraege_iv: row[:beitraege_iv],
        sonstige_beitraege: row[:sonstige_beitraege],
        spenden_zweckgebunden: row[:direkte_spenden],
        spenden_nicht_zweckgebunden: row_with_method[:indirekte_spenden]
      }
    end

    def personalaufwand(table)
      [
        CostAccountingRow.new(*report_data(:lohnaufwand, table)),
        CostAccountingRow.new(*report_data(:sozialversicherungsaufwand, table)),
        CostAccountingRow.new(*report_data(:uebriger_personalaufwand, table))
      ].sum
    end

    def gemeinkosten(table)
      Array.new(3, nil) + report_data(:total_umlagen, table)[3..-1]
    end

    def indirekte_spenden(table)
      data = report_data(:indirekte_spenden, table)

      [data[0], nil, nil, *data[3..-1]]
    end
  end
end
