# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2022::Export::Tabular::TimeRecords
  class LufebProVerein
    include Featureperioden::Domain

    class << self
      def csv(stats)
        Export::Csv::Generator.new(new(stats)).call
      end
    end

    delegate :year, to: :stats

    attr_reader :stats

    # Fp2022::TimeRecords::LufebProVerein
    def initialize(stats)
      @stats = stats
    end

    def data_rows(_format = :csv)
      return enum_for(:data_rows) unless block_given?

      yield empty_row

      @stats.vereine.each do |group|
        yield group_label(group)
        yield group_row(group, :general)
        yield group_row(group, :specific_with_grundlagen)
        yield group_row(group, :promoting)
        yield empty_row
      end
    end

    def labels
      [fp_t('group_or_stat'), '']
    end

    private

    def group_label(group)
      [group.name, nil]
    end

    def group_row(group, stat)
      [fp_t(stat), send(stat, group) || 0]
    end

    def empty_row
      [nil, nil]
    end

    def general(group)
      @stats.lufeb_data_for(group.id).general
    end

    def promoting(group)
      @stats.lufeb_data_for(group.id).promoting
    end

    def specific_with_grundlagen(group) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      data = @stats.lufeb_data_for(group.id) # could be time_record_data, if I had the linelength

      kostenrechnung = fp_class('CostAccounting::Table').new(group, year)

      vollkosten_tp = kostenrechnung.value_of('vollkosten', 'treffpunkte').to_f
      vollkosten_alle =
        if vollkosten_tp.positive?
          vollkosten_tp +
            kostenrechnung.value_of('vollkosten', 'blockkurse').to_f +
            kostenrechnung.value_of('vollkosten', 'tageskurse').to_f +
            kostenrechnung.value_of('vollkosten', 'jahreskurse').to_f
        else
          0
        end

      kurs_anteil =
        if vollkosten_alle.positive?
          ((vollkosten_alle - vollkosten_tp) / vollkosten_alle)
        else
          1
        end

      data.specific.to_d + data.lufeb_grundlagen.to_d + (data.kurse_grundlagen.to_d * kurs_anteil)
    end

    def fp_t(field, options = {})
      I18n.t(field, options.merge(scope: fp_i18n_scope('time_records.lufeb_times')))
    end
  end
end
