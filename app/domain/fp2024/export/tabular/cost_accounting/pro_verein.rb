# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2024::Export::Tabular::CostAccounting
  class ProVerein
    include Featureperioden::Domain

    class << self
      def csv(stats)
        Export::Csv::Generator.new(new(stats)).call
      end
    end

    delegate :year, to: :stats

    attr_reader :stats

    # Fp2024::CostAccounting::ProVerein
    def initialize(stats)
      @stats = stats
    end

    def labels
      empty_row
    end

    def data_rows(_format = :csv)
      return enum_for(:data_rows) unless block_given?

      @stats.vereine.each do |group|
        yield group_row(group)
        yield label_row
        @stats.data_for(group).each do |row_label, row_data|
          yield data_row(row_label, row_data)
        end

        4.times { yield empty_row }
      end
    end

    private

    def label_keys
      @label_keys ||= [:type] + @stats.class::CostAccountingRow.empty_row.members
    end

    def empty_row
      Array.new(label_keys.size, nil)
    end

    def label_row
      label_keys.map { |key| fp_t(key) }
    end

    def group_row(group)
      [group.name, group.bsv_number, *Array.new(label_keys.count - 2, nil)]
    end

    def data_row(row_label, row_data)
      [fp_t(row_label), *row_data.members.map { |attr| row_data.send(attr) }]
    end

    def fp_t(field, options = {})
      I18n.t(field, **options.merge(scope: fp_i18n_scope("cost_accounting.pro_verein")))
    end
  end
end
