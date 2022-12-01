require 'spec_helper'

#  Copyright (c) 2012-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

describe Role do
    # we don't want to check the test roles of the base project
    base_project_testroles = [
      Group::BottomGroup::Leader,
      Group::BottomGroup::Member,
      Group::BottomLayer::Leader,
      Group::BottomLayer::LocalGuide,
      Group::BottomLayer::Member,
      Group::GlobalGroup::Leader,
      Group::GlobalGroup::Member,
      Group::TopGroup::Leader,
      Group::TopGroup::LocalGuide,
      Group::TopGroup::Secretary,
      Group::TopGroup::LocalSecretary,
      Group::TopGroup::Member,
      Group::TopLayer::TopAdmin,
    ]

    (Role.subclasses - base_project_testroles).each do |role|
      it "#{role.name} has permissions so must have two_factor_authentication_enforced=true" do
        if role.permissions.present?
          expect(role).to be_two_factor_authentication_enforced
        end
      end

    end
end
