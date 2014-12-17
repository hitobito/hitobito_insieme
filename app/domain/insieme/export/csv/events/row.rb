# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Export::Csv::Events
  module Row

    extend ActiveSupport::Concern

    included do
      attr_reader :course_record, :participations_all_count, :participations_teamers_count,
                  :participations_participants_count
    end

    def initialize(entry)
      @course_record = entry.course_record

      filter = ::Event::ParticipationFilter.new(entry, nil)
      filter.list_entries
      @participations_all_count = filter.counts['all']
      @participations_teamers_count = filter.counts['teamers']
      @participations_participants_count = filter.counts['participants']

      super(entry)
    end

    def leistungskategorie
      entry.leistungskategorie && I18n.t('activerecord.attributes.event/course.' \
                                         "leistungskategorien.#{entry.leistungskategorie}")
    end

    def subventioniert
      entry.course_record && entry.course_record.subventioniert
    end

    def inputkriterien
      entry.course_record && entry.course_record.inputkriterien
    end

    def kursart
      entry.course_record && entry.course_record.kursart &&
        I18n.t('activerecord.attributes.event/course_record.' \
               "kursarten.#{entry.course_record.kursart}")
    end

    def spezielle_unterkunft
      entry.course_record && entry.course_record.spezielle_unterkunft
    end

  end
end
