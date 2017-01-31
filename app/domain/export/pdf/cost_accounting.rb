# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export::Pdf
  class CostAccounting < ::Export::Base
    include CostAccounting::Style

    class_attribute :row_class
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
      data = generate_data
      pdf.table(data) do |t|
        style_table(t)
      end
    end

    def generate_data
      data = []
      data += [labels]
      data += data_rows
      data
    end

    def data_rows
      @list.collect do |entry|
        values(entry)
      end
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
