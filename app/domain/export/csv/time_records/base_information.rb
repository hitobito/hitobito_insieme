# encoding: utf-8

#  Copyright (c) 2016 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export
  module Csv
    module TimeRecords
      class BaseInformation

        class << self
          def export(table)
            Export::Csv::Generator.new(new(table)).csv
          end
        end

        attr_reader :table

        def initialize(table)
          @table = table
        end

        def to_csv(generator)
          generator << labels
          table.reports.values.each do |report|
            generator << report_values(report)
          end
        end

        private

        def labels
          [nil,
           I18n.t('time_records.index.paragraph_74'),
           I18n.t('time_records.index.not_paragraph_74'),
           I18n.t('time_records.index.whole_organization')]
        end

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
