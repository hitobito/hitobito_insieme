# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::ParticipationsController, type: :controller do

  render_views

  let(:test_entry) { event_participations(:top_participant) }
  let(:course) { test_entry.event }
  let(:group)  { course.groups.first }

  let(:dom) { Capybara::Node::Simple.new(response.body) }

  before { sign_in(people(:top_leader)) }

  context 'active memberships' do
    it 'contains heading' do
      get :show, params: { group_id: group.id, event_id: course.id, id: test_entry.id }
      expect(dom).to have_content('Aktivmitgliedschaften')
    end
  end
end
