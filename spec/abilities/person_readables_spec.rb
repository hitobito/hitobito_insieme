#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe PersonReadables do
  let(:action) { action }
  let(:user) { role.person.reload }
  let(:ability) { PersonReadables.new(user, nil) }

  let(:all_accessibles) { Person.accessible_by(ability) }

  subject { all_accessibles }

  context :contact_data do
    let(:gremium) { Fabricate(Group::RegionalvereinGremium.name.to_sym, parent: groups(:be)) }
    let(:role) { Fabricate(Group::RegionalvereinGremium::Leitung.name.to_sym, group: gremium) }

    it "may get other person with contact data" do
      other = Fabricate(Group::Regionalverein::BerechtigungSekretariat.name.to_sym, group: groups(:be))
      is_expected.to include(other.person)
    end

    it "may not get other person with contact data in lower layer" do
      other = Fabricate(Group::Regionalverein::BerechtigungSekretariat.name.to_sym, group: groups(:seeland))
      is_expected.not_to include(other.person)
    end

    it "may not get other person with contact data in upper layer" do
      other = Fabricate(Group::Dachverein::BerechtigungAdmin.name.to_sym, group: groups(:dachverein))
      is_expected.not_to include(other.person)
    end
  end
end
