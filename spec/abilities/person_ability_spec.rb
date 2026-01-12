#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe PersonAbility do
  let(:role) { Fabricate(role_name.to_sym, group: group) }
  let(:ability) { Ability.new(role.person.reload) }

  subject { ability }

  context :contact_data do
    let(:gremium) { Fabricate(Group::RegionalvereinGremium.name.to_sym, parent: groups(:be)) }
    let(:role) { Fabricate(Group::RegionalvereinGremium::Leitung.name.to_sym, group: gremium) }

    context "in same layer" do
      it "may show person with contact data" do
        other = Fabricate(Group::Regionalverein::BerechtigungSekretariat.sti_name, group: groups(:be)).person
        is_expected.to be_able_to(:show, other)
      end

      it "may index people in own group" do
        is_expected.to be_able_to(:index_people, gremium)
      end

      it "may index people in other group" do
        is_expected.to be_able_to(:index_people, gremium)
      end
    end

    context "in lower layer" do
      let(:subgroup) { groups(:seeland) }

      it "may not show person with contact data" do
        other = Fabricate(Group::Regionalverein::Controlling.name.to_sym, group: subgroup).person
        is_expected.not_to be_able_to(:show, other)
      end

      it "may not index people" do
        is_expected.not_to be_able_to(:index_people, subgroup)
      end
    end
  end
end
