# encoding: utf-8

#  Copyright (c) 2012-2016, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.
#

module Export::Pdf
  class CostAccounting::Row
    class_attribute :dynamic_attributes
    self.dynamic_attributes = {}

    attr_reader :entry

    def initialize(entry, _format = nil)
      @entry = entry
    end

    def fetch(attr)
      value = value_for(attr)
      value.is_a?(BigDecimal) ? currency_format(value) : value
    end

    private

    def value_for(attr)
      if respond_to?(attr, true)
        send(attr)
      else
        entry.send(attr)
      end
    end

    def currency_format(number)
      format('%.2f', number.to_f).to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1'")
    end

    def report
      entry.human_name
    end
  end
end
