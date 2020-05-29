# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Vp2020::Export::Tabular::Events
  class DetailList < ::Export::Tabular::Events::List

    def initialize(list, group_name, year)
      @group_name = group_name
      @year = year
      @list = list
      add_header_rows
    end

    COURSE_RECORD_ATTRS = [
      :kursdauer,
      ## effektiv teilnehmende
      :teilnehmende_behinderte, :teilnehmende_mehrfachbehinderte,
      :teilnehmende_angehoerige, :teilnehmende_weitere,
      ## absenztage
      :absenzen_behinderte, :absenzen_angehoerige, :absenzen_weitere,
      ## total teilnehmerinnentage
      :tage_behinderte, :tage_angehoerige, :tage_weitere,
      ## betreuerinnen
      :leiterinnen, :fachpersonen,
      :hilfspersonal_mit_honorar, :hilfspersonal_ohne_honorar,
      ## personal ohne betreuungsfunktion
      :kuechenpersonal,
      ## direkter aufwand
      :honorare_inkl_sozialversicherung, :unterkunft, :uebriges,
      :direkter_aufwand,
      # ertrag
      :beitraege_teilnehmende,
      # auswertungen
      :gemeinkostenanteil, :total_vollkosten,
      :total_tage_teilnehmende, :vollkosten_pro_le,
      :zugeteilte_kategorie
    ].freeze

    self.row_class = Export::Tabular::Events::DetailRow

    private

    def build_attribute_labels
      super.tap do |labels|
        add_additional_course_record_labels(labels)
      end
    end

    def add_additional_course_record_labels(labels)
      COURSE_RECORD_ATTRS.each do |attr|
        add_course_record_label(labels, attr)
      end
    end

    def add_header_rows
      header_rows << []
      header_rows << title_header_values
      header_rows << []
    end

    def title_header_values
      row = Array.new(18)
      row[0] = @group_name
      row[3] = reporting_year
      row[12] = document_title
      row[66] = "#{I18n.t('global.printed')}: "
      row[67] = printed_at
      row
    end

    def document_title
      # translate
      str = ''
      str << I18n.t('event.lists.courses.xlsx_export_title')
      str << ': '
      str << title
      str
    end

    def title
      I18n.t('export/tabular/events.title')
    end

    def reporting_year
      str = ''
      str << I18n.t('cost_accounting.index.reporting_year')
      str << ': '
      str << @year.to_s
      str
    end

    def printed_at
      str = ''
      str << I18n.l(Time.zone.today)
      str << Time.zone.now.strftime(' %H:%M')
      str
    end

  end
end
