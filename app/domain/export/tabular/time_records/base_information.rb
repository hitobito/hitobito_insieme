# frozen_string_literal: true
#  Copyright (c) 2016 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export
  module Tabular
    module TimeRecords
      class BaseInformation

        class << self
          def csv(table)
            Export::Csv::Generator.new(new(table)).call
          end
        end

        attr_reader :table

        def initialize(table)
          @table = table
        end

        def data_rows(_format = nil)
          return enum_for(:data_rows) unless block_given?

          table.reports.values.each do |report|
            yield report_values(report)
          end
        end

        def labels
          [nil,
           I18n.t('time_record.base_informations.index.paragraph_74'),
           I18n.t('time_record.base_informations.index.not_paragraph_74'),
           I18n.t('time_record.base_informations.index.whole_organization')]
        end

        private

        def report_values(report)
          [report.human_name,
           report.paragraph_74,
           report.not_paragraph_74,
           report.total]
        end

      end
    end
  end
end
