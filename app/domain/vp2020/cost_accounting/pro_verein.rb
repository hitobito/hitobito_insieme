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

    # def vereine
    # end

    # def data_for(verein)
    #   @data_for[verein.id] ||= fetch_data_for(verein)
    # end

    # Aufwand/Ertrag FiBu || FiBu - KLR
    # Abgrenzungen FiBu || Abgrenzung
    # --> leer <-- KLR
    # Gemeinkosten (Personal/Räuml. keiten/Verwaltung/ Mittelbeschaffung) --> sum
    # --> ? <-- Sozialberatung
    # --> leer <-- Bauberatung
    # --> leer <-- Rechtsberatung
    # --> leer <-- Vermittlung Betreuung
    # --> leer <-- Begleitetes Wohnen
    # Medien und Publikationen
    # Semester-/Jahreskuse
    # Blockkurse
    # Tageskurse
    # Treffpunkte
    # LUFEB
    CostAccountingRow = Struct.new(
      :aufwand_ertrag_fibu, :abgrenzung, :gemeinkosten, :media,
      :jahreskurse, :blockkurse, :tageskurse, :treffpunkte, :lufeb
    ) do
      def self.empty_row
        new(*Array.new(9, nil))
      end

      def +(other)
        to_a.zip(other.to_a).map do |self_value, other_value|
          self_value + other_value
        end
      end

      [:klr].each do |empty_col|
        define_method(empty_col) { nil }
      end

      [
        :sozialberatung,
        :bauberatung,
        :rechtsberatung,
        :vermittlung,
        :wohnbegleitung
      ].each do |unused_col|
        define_method(unused_col) { 0 }
      end
    end

    private

    def report_data(report, table) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      [
        table.value_of(report.to_s, 'aufwand_ertrag_fibu').to_d,
        table.value_of(report.to_s, 'abgrenzung_fibu').to_d,
        [
          table.value_of(report.to_s, 'verwaltung').to_d,
          table.value_of(report.to_s, 'raumlichkeiten').to_d,
          table.value_of(report.to_s, 'mittelbeschaffung').to_d
        ].sum,
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

      {
        # personalaufwand: [
        #   row[:lohnaufwand],
        #   row[:sozialversicherungsaufwand],
        #   row[:uebriger_personalaufwand]
        # ].sum,
        # Personalaufwand = Lohnaufwand + Sozialversicherungsaufwand + übriger Personalaufwand
        personalaufwand: [
          CostAccountingRow.new(*report_data(:lohnaufwand, table)),
          CostAccountingRow.new(*report_data(:sozialversicherungsaufwand, table)),
          CostAccountingRow.new(*report_data(:uebriger_personalaufwand, table))
        ].sum,
        # Honorare = Honorare
        honorare: CostAccountingRow.new(*report_data(:honorare, table)),
        # Sachaufwand = Raumaufwand + Übriger Sachaufwand
        sachaufwand: [
          CostAccountingRow.new(*report_data(:raumaufwand, table)),
          CostAccountingRow.new(*report_data(:uebriger_sachaufwand, table))
        ].sum,
        # Aufwand = leere Zeile
        # aufwand: empty,
        aufwand: CostAccountingRow.empty_row,
        # Gemeinkosten = Gemeinkosten
        gemeinkosten: CostAccountingRow.new(*report_data(:total_umlagen, table)),
        # Umlagen = leere Zeile
        umlagen: CostAccountingRow.empty_row,
        # Total Aufwand & Umlagen = leere Zeile
        total_aufwand: CostAccountingRow.empty_row,
        # Leistungen = Leistungsertrag
        leistungen: CostAccountingRow.new(*report_data(:leistungsertrag, table)),
        # Beiträge IV/AHV = Beiträge IV
        beitraege_iv: CostAccountingRow.new(*report_data(:beitraege_iv, table)),
        # Sonstige Beiträge Bund/Kant./Geme. = Beiträge Kantone, Gemeinden
        sonstige_beitraege: CostAccoutingRow.new(*report_data(:sonstige_beitraege, table)),
        # Zweckgeb. Spenden/sonstige Erträge = Direkte Spenden (Art. 74)
        spenden_zweckgebunden: CostAccoutingRow.new(*report_data(:direkte_spenden, table)),
        # Nicht zweckgeb. Spenden/sonstige Erträge = Indirekte Spenden geschlüsselt
        spenden_nicht_zweckgebunden: CostAccountingRow.new(*report_data(:indirekte_spenden, table))
      }
    end
  end
end
