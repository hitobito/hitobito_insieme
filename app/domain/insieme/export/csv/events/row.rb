# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Export::Csv::Events
  module Row

    extend ActiveSupport::Concern

    included do
      delegate :subventioniert, :inputkriterien, :spezielle_unterkunft, :anzahl_kurse,
               to: :course_record, allow_nil: true
    end

    def leistungskategorie
      entry.leistungskategorie && I18n.t('activerecord.attributes.event/course.' \
                                         "leistungskategorien.#{entry.leistungskategorie}")
    end

    def kursart
      course_record && course_record.kursart &&
        I18n.t('activerecord.attributes.event/course_record.' \
               "kursarten.#{entry.course_record.kursart}")
    end

    private

    def course_record
      entry.course_record
    end

  end
end
