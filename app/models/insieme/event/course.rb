# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Event
    module Course
      extend ActiveSupport::Concern

      included do
        self.role_types = [::Event::Course::Role::LeaderAdmin,
                           ::Event::Course::Role::LeaderReporting,
                           ::Event::Course::Role::LeaderBasic,
                           ::Event::Course::Role::Expert,
                           ::Event::Course::Role::HelperPaid,
                           ::Event::Course::Role::HelperUnpaid,
                           ::Event::Course::Role::Kitchen,
                           ::Event::Course::Role::Challenged,
                           ::Event::Course::Role::Affiliated,
                           ::Event::Course::Role::NotEntitledForBenefit]

        self.used_attributes -= [:kind_id, :group_ids]
        self.used_attributes += [:leistungskategorie]

        has_one :course_record, foreign_key: :event_id, dependent: :destroy, inverse_of: :event
        accepts_nested_attributes_for :course_record

        attr_readonly :leistungskategorie

        LEISTUNGSKATEGORIEN = %w(bk tk sk)
        validates :leistungskategorie, inclusion: LEISTUNGSKATEGORIEN


        def self.available_leistungskategorien
          LEISTUNGSKATEGORIEN.map do |period|
            [period, I18n.t("activerecord.attributes.event/course.leistungskategorien.#{period}")]
          end
        end
      end

      ### INSTANCE METHODS

      def years
        dates.
          map { |date| [date.start_at, date.finish_at] }.
          flatten.
          compact.
          map(&:year).
          uniq.
          sort
      end

    end
  end
end
