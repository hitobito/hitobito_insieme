# frozen_string_literal: true

#  Copyright (c) 2014-2021, Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Vp2021::Export::Xlsx::CostAccounting
  class Style < Export::Xlsx::Style

    BLACK = '000000'
    CURRENCY = 2

    self.style_definition_labels += [:total_label, :total_currency,
                                     :currency, :vereinsname,
                                     :reporting_jahr, :default_border,
                                     :centered_border,
                                     :box, :box_top_left, :box_top, :box_top_right]

    def column_widths
      [57.62]
    end

    def header_styles
      [nil, style_title_header_row, nil, style_combined_labels_row]
    end

    def row_styles
      [].tap do |row|
        row[4] = style_total_rows
        row[7] = style_total_rows
        row[8] = style_total_rows
        row[9] = style_total_rows
        row[15] = style_total_rows
        row[17] = style_total_rows
      end
    end

    def default_style_data_rows
      [:default_border, :centered_border] +
        Array.new(16, :currency)
    end

    def style_title_header_row
      [:vereinsname, :reporting_jahr] +
        Array.new(16, :centered)
    end

    def style_combined_labels_row
      Array.new(4, :centered) + [:box_top_left, :box_top, :box_top_right] + Array.new(13, :centered)
    end

    private

    def style_total_rows
      [:total_label] +
        Array.new(17, :total_currency)
    end

    # override default attribute labels style
    def attribute_labels_style
      default_border_style.deep_merge(
        style: {
          bg_color: LABEL_BACKGROUND,
          alignment: { text_rotation: 90, vertical: :center, horizontal: :center }
        },
        height: 230
      )
    end

    # override default style
    def default_style
      {
        style: {
          sz: 16,
          font_name: Settings.xlsx.font_name,
          alignment: { horizontal: :left }
        }
      }
    end

    def total_label_style
      default_border_style.deep_merge(style: { bg_color: LABEL_BACKGROUND })
    end

    def total_currency_style
      currency_style.deep_merge(style: { bg_color: LABEL_BACKGROUND })
    end

    def currency_style
      centered_border_style.deep_merge(
        style: {
          num_fmt: CURRENCY,
          alignment: { horizontal: :center }
        }
      )
    end

    def vereinsname_style
      default_style.deep_merge(style: { sz: 20 })
    end

    def reporting_jahr_style
      centered_style.merge(style: { sz: 20, font_name: Settings.xlsx.font_name })
    end

    def box_top_left_style
      box_style.deep_merge(style: { border: { edges: [:top, :left] } })
    end

    def box_top_style
      box_style.deep_merge(style: { border: { edges: [:top] } })
    end

    def box_top_right_style
      box_style.deep_merge(style: { border: { edges: [:top, :right] } })
    end

    def box_style
      centered_border_style.deep_merge(style: { bg_color: LABEL_BACKGROUND })
    end

    def default_border_style
      default_style.deep_merge(border_styling)
    end

    def centered_border_style
      centered_style.deep_merge(border_styling)
    end

    def border_styling
      { style: { border: { style: :thin, color: BLACK } } }
    end

    def centered_style
      default_style.deep_merge(style: { alignment: { horizontal: :center } })
    end
  end
end
