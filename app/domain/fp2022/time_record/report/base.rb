# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2022
  class TimeRecord::Report::Base

    FIELDS = %w(paragraph_74 not_paragraph_74 total).freeze

    class << self
      def key
        name.demodulize.underscore
      end

      def human_name
        I18n.t("time_records.report.#{key}.name")
      end
    end

    attr_reader :table

    # The kind of the report, e.g. controlling, capital_substrate
    class_attribute :kind

    delegate :key, :human_name, to: :class

    def initialize(table)
      @table = table
    end

    # define accessor methods for all fields, returning nil
    FIELDS.each do |f|
      define_method(f) {}
    end

    private

    def record
      @record ||= table.record(key)
    end
  end
end
