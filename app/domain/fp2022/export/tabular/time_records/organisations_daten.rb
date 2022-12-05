# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2022::Export::Tabular::TimeRecords
  class OrganisationsDaten
    include Featureperioden::Domain

    class << self
      def csv(stats)
        Export::Csv::Generator.new(new(stats)).call
      end
    end

    delegate :year, to: :stats

    attr_reader :stats

    def initialize(stats)
      @stats = stats
    end

    def data_rows(_format = :csv)
      return enum_for(:data_rows) unless block_given?

      yield empty_row

      @stats.vereine.each do |group|
        yield group_label(group)
        yield group_row(group, :angestellte_insgesamt)
        yield group_row(group, :angestellte_art_74)
        yield group_row(group, :freiwillige_insgesamt)
        yield group_row(group, :freiwillige_art_74)
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
      [
        fp_t(stat),
        @stats.data_for(group).send(stat) || 0
      ]
    end

    def empty_row
      [nil, nil]
    end

    def fp_t(field, options = {})
      I18n.t(field, options.merge(scope: fp_i18n_scope('time_records.group_data')))
    end
  end
end
