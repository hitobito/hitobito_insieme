# encoding: utf-8

#  Copyright (c) 2014, Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::RolesController do

  let(:group) { groups(:dachverein) }
  let(:course) { events(:top_course) }

  let(:user) { people(:top_leader) }

  before { sign_in(user) }

  context 'GET edit' do
    it 'offers team roles for leader' do
      role = event_roles(:top_leader)

      get :edit,
          group_id: group.id,
          event_id: course.id,
          id: role.id

      expect(assigns(:possible_types)).to eq [
        ::Event::Course::Role::LeaderAdmin,
        ::Event::Course::Role::LeaderReporting,
        ::Event::Course::Role::LeaderBasic,
        ::Event::Course::Role::Expert,
        ::Event::Course::Role::HelperPaid,
        ::Event::Course::Role::HelperUnpaid,
        ::Event::Course::Role::Caretaker,
        ::Event::Course::Role::Kitchen ]
    end

    it 'offers participant roles for participant' do
      role = Fabricate(::Event::Course::Role::Challenged.name.to_sym,
                       participation: Fabricate(:event_participation, event: course))

      get :edit,
          group_id: group.id,
          event_id: course.id,
          id: role.id

      expect(assigns(:possible_types)).to eq [
        ::Event::Course::Role::Challenged,
        ::Event::Course::Role::Affiliated,
        ::Event::Course::Role::NotEntitledForBenefit]
    end
  end
end
