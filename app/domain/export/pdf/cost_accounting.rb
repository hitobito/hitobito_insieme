#  Copyright (c) 2016-2017 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export::Pdf
  class CostAccounting < ::Export::Tabular::Base
    include CostAccounting::Style

    COLSPANS = { 22 => [0, 1, 2, 3, 4, 5, 6, 7],
                 23 => [0, 1, 2]
    }.freeze

    self.row_class = Row

    def initialize(list, group_name, year)
      @list = list
      @group_name = group_name
      @year = year
    end

    def generate
      pdf = Prawn::Document.new(page_size: 'A4', page_layout: :landscape)
      style_pdf(pdf)

      add_header(pdf)
      pdf.move_down 30
      cost_accounting_table(pdf)
      pdf.render
    end

    private

    def cost_accounting_table(pdf)
      data = [labels] + data_rows
      pdf.table(data) do |t|
        style_table(t)
      end
    end

    def data_rows
      @list.collect.with_index do |entry, row|
        row_content = []
        values(entry).each_with_index do |value, cell|
          next if skip_cell?(row, cell)
          row_content << cell_value(row, cell, value)
        end
        row_content
      end
    end

    def cell_value(row, cell, value)
      colspan_cell?(row, cell) ? colspan_cell(row, value) : value
    end

    def skip_cell?(row, cell)
      return false unless COLSPANS.has_key?(row)
      return false if colspan_cell?(row, cell)
      COLSPANS[row].include?(cell)
    end

    def colspan_cell?(row, cell)
      return false unless COLSPANS.has_key?(row)
      COLSPANS[row].first == cell
    end

    def colspan_cell(row, value)
      colspan_length = COLSPANS[row].count
      { content: value, colspan: colspan_length }
    end

    def add_header(pdf)
      pdf.draw_text(@group_name, at: [0, 500], size: 9)
      pdf.draw_text("#{I18n.t('cost_accounting.index.reporting_year')}: #{@year}",
                    at: [300, 500],
                    size: 9)
      pdf.draw_text(printed_at, at: [680, 500])
    end

    def printed_at
      date = I18n.l(Time.zone.today)
      time = Time.zone.now.strftime(' %H:%M')
      "Druck:   #{date} #{time}"
    end

    def human(field)
      I18n.t("activerecord.attributes.cost_accounting_record.#{field}")
    end

    def build_attribute_labels
      {}.tap do |labels|
        labels[:report] = human(:report)

        ::CostAccounting::Report::Base::FIELDS.each do |field|
          labels[field.to_sym] = human(field)
        end
      end
    end
  end
end
