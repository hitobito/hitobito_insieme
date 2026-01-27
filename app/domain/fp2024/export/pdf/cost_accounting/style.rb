# frozen_string_literal: true

#  Copyright (c) 2012-2016, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.
#

module Fp2024::Export::Pdf::CostAccounting::Style
  COLORED_ROWS = [0, 5, 8, 9, 10, 16, 18].freeze
  CUSTOM_WIDTH_COLUMNS = [].freeze

  def style_pdf(pdf)
    pdf.font "Helvetica", size: 6
  end

  def style_table(table)
    table.column(1..16).align = :center
    table.column(1..16).padding_left = 2
    table.column(1..16).padding_right = 2
    table.column(0).width = 210
    cell_style(table)
    color_table(table)
    align_header(table)
    table_width(table)
  end

  private

  def cell_style(table)
    table.cells.border_width = 0.5
    table.cells.height = 14
    table.cells.padding_top = 2
    table.cells.overflow = :ellipse
  end

  def color_table(table)
    COLORED_ROWS.each do |row_index|
      table.row(row_index).background_color = "BBBBBB"
    end
  end

  def align_header(table)
    header_row = table.cells.row(0)
    header_row.content_width = 200
    header_row.rotate = 90
    header_row.rotate_around = :center
    header_row.align = :left
    header_row.height = 80
    header_row.width = 24
    header_row.padding_top = -5
    header_row.padding_left = 12
  end

  def table_width(table)
    CUSTOM_WIDTH_COLUMNS.each do |column_index|
      table.column(column_index).width = 8
      table.column(column_index).row(1..26).content = ""
      table.column(column_index).row(0).padding_left = 3
    end
  end
end
