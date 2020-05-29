# frozen_string_literal: true

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Export::Xlsx::Events
  class Style < Export::Xlsx::Style

    BLACK = '000000'
    CURRENCY = 2
    DATE = 14

    self.data_row_height = 130

    self.style_definition_labels += [:title, :default_border,
                                     :centered_border, :vertical_centered,
                                     :currency, :date,
                                     :centered_border_small, :centered_border_wrap,
                                     :vertical_centered_wrap]

    # rubocop:disable Metrics/MethodLength
    def column_widths
      [20, 20, 3.3, 20, 2.57, 7.43] + # #1-6
      Array.new(9, 2.57) + # #7-15
      Array.new(12, 3) + # #16-27
      [20, 5.7, 9.14, 9.14, 2.57, 3.7, 3, 7] + # #28-35
      [2.57, 2.57, 17.14, 4.29, 3.71, 2.57, 11.57, 3.71, 2.57] + # #36-44
      Array.new(8, 4.29) + # #45-52
      Array.new(3, 6.29) + # #53-55
      Array.new(5, 2.57) + # #56-60
      Array.new(3, 8.14) + # #61-63
      [8.14, 8.14, 2.57, 8.14, 9.14, 8.14, 2.54] # #64-70
    end

    def default_style_data_rows
      Array.new(2, :centered_border_wrap) +
      [:centered_border] +
      [:centered_border_small] +
      [:centered_border] +
      [:vertical_centered_wrap] +
      Array.new(21, :vertical_centered) +
      [:centered_border_small] +
      [:currency] +
      [:date, :date] +
      Array.new(29, :centered_border) +
      Array.new(4, :currency) +
      Array.new(2, :centered_border) +
      Array.new(3, :currency) +
      [:centered_border]
    end
    # rubocop:enable Metrics/MethodLength

    def header_styles
      [nil, style_title_header_row, nil]
    end

    def row_styles
      [].tap do |row|
      end
    end

    def style_title_header_row
      [:title] +
      Array.new(3, :title) +
      Array.new(12, :title) +
      Array.new(31, :default) +
      Array.new(33, :default) +
      Array.new(66, :default) +
      Array.new(67, :default)
    end

    private

    # override default style
    def default_style
      { style: {
        font_name: Settings.xlsx.font_name, sz: 10, alignment: { horizontal: :left }
      } }
    end

    # override default attribute labels style
    def attribute_labels_style
      default_border_style.deep_merge(
        style: {
          bg_color: LABEL_BACKGROUND,
          alignment: { text_rotation: 90, vertical: :center, horizontal: :center }
        },
        height: 300
      )
    end

    def vertical_centered_wrap_style
      vertical_centered_style.deep_merge(
        style: {
          alignment: { wrap_text: true }
        }
      )
    end

    def vertical_centered_style
      default_border_style.deep_merge(
        style: {
          alignment: { text_rotation: 90, vertical: :center, horizontal: :center }
        }
      )
    end

    def default_border_style
      default_style.deep_merge(border_styling)
    end

    def centered_border_style
      centered_style.deep_merge(border_styling).deep_merge(
        style: {
          alignment: { vertical: :center, horizontal: :center }
        }
      )
    end

    def centered_border_wrap_style
      centered_border_style.deep_merge(style: { alignment: { wrap_text: true } })
    end

    def centered_border_small_style
      centered_border_style.deep_merge(style: { sz: 8, alignment: { wrap_text: true } })
    end

    def currency_style
      centered_border_style.deep_merge(
        style: { num_fmt: CURRENCY }
      )
    end

    def date_style
      centered_border_style.deep_merge(
        style: { num_fmt: DATE }
      )
    end

    def border_styling
      { style: { border: { style: :thin, color: BLACK } } }
    end

    def title_style
      default_style.deep_merge(style: { sz: 16 })
    end
  end
end
