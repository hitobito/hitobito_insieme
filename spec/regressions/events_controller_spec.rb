# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe EventsController, type: :controller do

  render_views

  let(:group) { groups(:be) }
  let(:dom) { Capybara::Node::Simple.new(response.body) }

  before { sign_in(people(:top_leader)) }

  context 'GET index' do
    context '.csv' do
      it 'renders event csv' do
        get :index, group_id: groups(:dachverein).id, year: 2014, format: :csv
        response.body.lines.should have(2).items
      end

      it 'renders course csv' do
        get :index, group_id: group.id, year: 2014, format: :csv, type: Event::Course.sti_name
        response.body.lines.should have(2).items
      end
    end
  end

  context 'course reporting tab' do
    context 'simple event' do
      it 'should not be visible' do
        event = Fabricate(:event, groups: [group])

        get :show, group_id: group.id, id: event.id
        dom.should_not have_content 'Kursabschluss'
      end
    end

    context 'course' do
      it 'should be visible to top leader' do
        event = Fabricate(:course, groups: [group], kind: Event::Kind.first,
                          leistungskategorie: 'bk')

        get :show, group_id: group.id, id: event.id
        dom.should have_content 'Kursabschluss'
      end

      it 'should not be visible to participants' do
        event = Fabricate(:course, groups: [group], kind: Event::Kind.first,
                          leistungskategorie: 'bk')
        role = Fabricate(Group::Regionalverein::Versandadresse.name.to_sym, group: group)
        Fabricate(Event::Role::Participant.name.to_sym,
                  participation: Fabricate(:event_participation,
                                           event: event, person: role.person))
        sign_in(role.person)

        get :show, group_id: group.id, id: event.id
        dom.should_not have_content 'Kursabschluss'
      end
    end
  end

end
