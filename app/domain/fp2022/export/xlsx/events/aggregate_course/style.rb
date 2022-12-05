# frozen_string_literal: true

#  Copyright (c) 2020 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Fp2022::Export::Xlsx::Events::AggregateCourse
  class Style < ::Export::Xlsx::Style

    BLACK = '000000'
    CURRENCY = 2
    DATE = 14

    self.data_row_height = 50

    self.style_definition_labels += [:title, :default_border,
                                     :centered_border, :vertical_centered,
                                     :currency, :date,
                                     :centered_border_small, :centered_border_wrap]

    def column_widths
      column_style_information.map(&:width)
    end

    def default_style_data_rows
      column_style_information.map(&:style)
    end

    def header_styles
      [nil, style_title_header_row, nil]
    end

    def row_styles
      [].tap do |row|
      end
    end

    ColumnStyleInformation = Struct.new(:width, :style)

    def column_style_information # rubocop:disable Metrics/MethodLength
      @column_style_information ||= [
        [18,    :centered_border_wrap],
        [12.86, :centered_border_wrap],
        [20,    :centered_border_small],
        [18,    :centered_border_wrap],
        [18,    :centered_border_wrap],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :currency],
        [2.57,  :currency],
        [2.57,  :currency],
        [2.57,  :currency],
        [2.57,  :currency],
        [2.57,  :currency],
        [2.57,  :currency],
        [2.57,  :vertical_centered],
        [2.57,  :vertical_centered],
        [2.57,  :currency],
        [2.57,  :currency]
      ].map { |width, style| ColumnStyleInformation.new(width, style) }
    end

    def style_title_header_row
      [:title] +
        Array.new(3, :title) +
        Array.new(12, :title) +
        Array.new(31, :default) +
        Array.new(33, :default)
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
        height: 285
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
      vertical_centered_style.deep_merge(
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
