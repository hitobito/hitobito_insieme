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
                           ::Event::Course::Role::Caregiver,
                           ::Event::Course::Role::Kitchen,
                           ::Event::Course::Role::Challenged]

        self.used_attributes -= [:kind_id]
        self.used_attributes += [:leistungskategorie]

        attr_readonly :leistungskategorie

        LEISTUNGSKATEGORIEN = %w(bk tk sk)
        validates_presence_of :leistungskategorie
        validates_inclusion_of :leistungskategorie, in: LEISTUNGSKATEGORIEN, allow_blank: true


        def self.available_leistungskategorien
          LEISTUNGSKATEGORIEN.map do |period|
            [period, I18n.t("activerecord.attributes.event/course.leistungskategorien.#{period}")]
          end
        end
      end
    end
  end
end
