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

    def report_data(report, table) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      [
        table.value_of(report.to_s, 'aufwand_ertrag_fibu').to_d,
        table.value_of(report.to_s, 'abgrenzung_fibu').to_d,
        [
          table.value_of(report.to_s, 'verwaltung').to_d,
          table.value_of(report.to_s, 'raeumlichkeiten').to_d,
          table.value_of(report.to_s, 'mittelbeschaffung').to_d
        ].sum,
        table.value_of(report.to_s, 'beratung').to_d,
        table.value_of(report.to_s, 'medien_und_publikationen').to_d,
        table.value_of(report.to_s, 'jahreskurse').to_d,
        table.value_of(report.to_s, 'blockkurse').to_d,
        table.value_of(report.to_s, 'tageskurse').to_d,
        table.value_of(report.to_s, 'treffpunkte').to_d,
        table.value_of(report.to_s, 'lufeb').to_d
      ]
    end

    def fetch_data_for(group) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      table = vp_class('CostAccounting::Table').new(group, year) # Vp2020::CostAccounting::Table

      # _row = ->(report) { CostAccountingRow.new(*report_data(report, table)) }
      # _empty = CostAccountingRow.new(*Array.new(9, nil))
      # personalaufwand: [
      #   row[:lohnaufwand],
      #   row[:sozialversicherungsaufwand],
      #   row[:uebriger_personalaufwand]
      # ].sum,
      # aufwand: empty,

      {
        personalaufwand: [
          CostAccountingRow.new(*report_data(:lohnaufwand, table)),
          CostAccountingRow.new(*report_data(:sozialversicherungsaufwand, table)),
          CostAccountingRow.new(*report_data(:uebriger_personalaufwand, table))
        ].sum,
        honorare: CostAccountingRow.new(*report_data(:honorare, table)),
        sachaufwand: [
          CostAccountingRow.new(*report_data(:raumaufwand, table)),
          CostAccountingRow.new(*report_data(:uebriger_sachaufwand, table))
        ].sum,
        aufwand: CostAccountingRow.empty_row,
        gemeinkosten: CostAccountingRow.new(*gemeinkosten(table)),
        umlagen: CostAccountingRow.empty_row,
        total_aufwand: CostAccountingRow.empty_row,
        leistungen: CostAccountingRow.new(*report_data(:leistungsertrag, table)),
        beitraege_iv: CostAccountingRow.new(*report_data(:beitraege_iv, table)),
        sonstige_beitraege: CostAccountingRow.new(*report_data(:sonstige_beitraege, table)),
        spenden_zweckgebunden: CostAccountingRow.new(*report_data(:direkte_spenden, table)),
        spenden_nicht_zweckgebunden: CostAccountingRow.new(*indirekte_spenden(table))
      }
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
