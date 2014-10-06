# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'


describe GroupAbility do

  let(:role) { Fabricate(role_name.to_sym, group: group)}
  let(:ability) { Ability.new(role.person.reload) }

  subject { ability }

  context 'Dachverein' do
    let(:group) { groups(:dachverein) }

    %w(Geschaeftsfuehrung Sekretariat Adressverwaltung).each do |role_class|
      context role_class do
        let(:role_name) { "Group::Dachverein::#{role_class}" }

        it "may :reporting on same group" do
          should be_able_to(:reporting, group)
        end

        it "may :reporting on layer below" do
          should be_able_to(:reporting, groups(:be))
        end

        it 'may show layer below' do
          should be_able_to(:show, groups(:be))
        end

        it 'may show group in layer below' do
          should be_able_to(:show, groups(:aktiv))
        end

        it 'may show externe organisation' do
          should be_able_to(:show, Group::ExterneOrganisation.new(parent: group))
        end

        it 'may create groups on same group' do
          should be_able_to(:create, Group.new(parent: group))
        end

        it 'may create groups on layer below' do
          should be_able_to(:create, Group.new(parent: groups(:be)))
        end

        it 'may update groups in layer below' do
          should be_able_to(:update, groups(:seeland))
        end

        it 'may destroy groups in layer below' do
          should be_able_to(:destroy, groups(:seeland))
        end

        it 'may destroy own group' do
          should_not be_able_to(:destroy, group)
        end

        it 'may reactivate groups in layer below' do
          should be_able_to(:reactivate, groups(:seeland))
        end

        it 'may view deleted subgroups in layer below' do
          should be_able_to(:deleted_subgroups, groups(:seeland))
        end
      end

    end
  end

  context 'Regionalverein' do
    let(:group) { groups(:be) }

    %w(Praesident Versandadresse Rechnungsadresse).each do |role_class|
      context role_class do
        let(:role_name) { "Group::Regionalverein::#{role_class}" }

        it "may not :reporting on same group" do
          should_not be_able_to(:reporting, group)
        end
      end
    end

    %w(Geschaeftsfuehrung Sekretariat Adressverwaltung Controlling).each do |role_class|
      context role_class do
        let(:role_name) { "Group::Regionalverein::#{role_class}" }
        let(:subgroup)  { Group.new(parent: group, layer_group_id: group.layer_group_id) }

        it "may :reporting on same group" do
          should be_able_to(:reporting, group)
        end

        it "may not :reporting on layer above" do
          should_not be_able_to(:reporting, groups(:dachverein))
        end

        it "may not :reporting on different group on same layer" do
          should_not be_able_to(:reporting, groups(:fr))
        end

        it 'may not create groups on same group' do
          should_not be_able_to(:create, subgroup)
        end

        it 'may read group in same layer' do
          should be_able_to(:show, subgroup)
        end

        it 'may show layer below' do
          should be_able_to(:show, groups(:seeland))
        end

        it 'may not show group in layer below' do
          should_not be_able_to(:show, groups(:aktiv))
        end

        it 'may show dachverein' do
          should be_able_to(:show, groups(:dachverein))
        end

        it 'may show regionalverein anywhere' do
          should be_able_to(:show, Group::Regionalverein.new(parent: groups(:dachverein)))
        end

        it 'may not show external organization' do
          should_not be_able_to(:show, Group::ExterneOrganisation.new(parent: groups(:dachverein)))
        end

        it 'may index events in same layer' do
          should be_able_to(:index_events, group)
        end

        it 'may not index events in layer below' do
          should_not be_able_to(:index_events, groups(:seeland))
        end

        it 'may index people in same layer' do
          should be_able_to(:index_people, group)
        end

        it 'may not index people in layer below' do
          should_not be_able_to(:index_people, groups(:seeland))
        end

        it 'may not index full people in layer below' do
          should_not be_able_to(:index_full_people, groups(:seeland))
        end

        it 'may not update groups in layer below' do
          should_not be_able_to(:update, groups(:seeland))
        end

        it 'may not destroy groups in layer below' do
          should_not be_able_to(:destroy, groups(:seeland))
        end

        it 'may not destroy groups in own layer' do
          should_not be_able_to(:destroy, subgroup)
        end

        it 'may not reactivate groups in layer below' do
          should_not be_able_to(:reactivate, groups(:seeland))
        end

        it 'may not view deleted subgroups in same layer' do
          should_not be_able_to(:deleted_subgroups, group)
        end

        it 'may not view deleted subgroups in layer below' do
          should_not be_able_to(:deleted_subgroups, groups(:seeland))
        end
      end
    end
  end

  context 'Externe Organisation' do
    let(:group) { Fabricate(Group::ExterneOrganisation.name.to_sym, parent: groups(:dachverein)) }

    context 'Geschaeftsfuehrung' do
      let(:role_name) { "Group::ExterneOrganisation::Geschaeftsfuehrung" }
      let(:subgroup)  { Group.new(parent: group, layer_group_id: group.layer_group_id) }

      it 'may read group in same layer' do
        should be_able_to(:show, subgroup)
      end

      it 'may not show layer below' do
        should_not be_able_to(:show, Group::ExterneOrganisation.new(parent: group))
      end

      it 'may show dachverein' do
        should be_able_to(:show, groups(:dachverein))
      end

      it 'may not show regionalverein anywhere' do
        should_not be_able_to(:show, groups(:be))
      end

      it 'may not show other external organization' do
        should_not be_able_to(:show, Group::ExterneOrganisation.new(parent: groups(:dachverein)))
      end
    end
  end



end
