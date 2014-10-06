# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'


describe PersonAccessibles do

  [:index, :layer_search, :deep_search, :global].each do |action|
    context action do
      let(:action) { action }
      let(:user)   { role.person.reload }
      let(:ability) { PersonAccessibles.new(user, action == :index ? group : nil) }

      let(:all_accessibles) do
        people = Person.accessible_by(ability)
        case action
        when :index then people
        when :layer_search then people.in_layer(group.layer_group)
        when :deep_search then people.in_or_below(group.layer_group)
        when :global then people
        end
      end


      subject { all_accessibles }


      context :contact_data do
        let(:role) { Fabricate(Group::Regionalverein::Controlling.name.to_sym, group: groups(:be)) }

        context 'in own group' do
          let(:group) { role.group }

          it 'may get himself' do
            should include(role.person)
          end

          it 'may get people with contact data' do
            other = Fabricate(Group::Regionalverein::Controlling.name.to_sym, group: group)
            should include(other.person)
          end
        end

        context 'in other group in same layer' do
          let(:group) { Fabricate(Group::RegionalvereinGremium.name.to_sym, parent: role.group) }

          it 'may get people with contact data' do
            other = Fabricate(Group::RegionalvereinGremium::Leitung.name.to_sym, group: group)
            should include(other.person)
          end

          it 'may not get people without contact data' do
            other = Fabricate(Group::RegionalvereinGremium::Mitglied.name.to_sym, group: group)
            should_not include(other.person)
          end
        end

        context 'in lower layer' do
          let(:group) { groups(:seeland) }

          it 'may not get person with contact data' do
            other = Fabricate(Group::Regionalverein::Controlling.name.to_sym, group: group)
            should_not include(other.person)
          end
        end
      end
    end
  end
end