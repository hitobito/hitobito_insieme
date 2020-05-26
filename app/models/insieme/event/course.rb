# encoding: utf-8
# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme
  module Event
    module Course
      extend ActiveSupport::Concern

      include ::Event::Reportable

      included do
        self.role_types = [::Event::Course::Role::LeaderAdmin,
                           ::Event::Course::Role::LeaderReporting,
                           ::Event::Course::Role::LeaderBasic,
                           ::Event::Course::Role::Expert,
                           ::Event::Course::Role::HelperPaid,
                           ::Event::Course::Role::HelperUnpaid,
                           ::Event::Course::Role::Caretaker,
                           ::Event::Course::Role::Kitchen,
                           ::Event::Course::Role::Challenged,
                           ::Event::Course::Role::Affiliated,
                           ::Event::Course::Role::NotEntitledForBenefit]

        self.used_attributes -= [:kind_id, :group_ids]
      end

    end
  end
end
