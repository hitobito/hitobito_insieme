# encoding: utf-8

#  Copyright (c) 2014, Insieme Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::RegisterController do

  let(:event) { Fabricate(:event, groups: [group], external_applications: true) }

  describe 'PUT register' do
    context 'in layer group' do
      let(:group) { groups(:be) }

      it 'creates external role in same group' do
        expect do
          put :register, params: { group_id: group.id, id: event.id, person: { last_name: 'foo', first_name: 'bar', email: 'foo@example.com', externally_registered: 'true' } }
        end.to change { Group::Regionalverein::External.where(group_id: group.id).count }.by(1)
      end
    end

    context 'in any group' do
      let(:group) { groups(:aktiv) }

      it 'creates external role in layer group' do
        expect do
          put :register, params: { group_id: group.id, id: event.id, person: { last_name: 'foo', first_name: 'bar', email: 'foo@example.com', externally_registered: 'true' } }
        end.to change { Group::Regionalverein::External.where(group_id: groups(:seeland).id).count }.by(1)
      end
    end
  end
end
