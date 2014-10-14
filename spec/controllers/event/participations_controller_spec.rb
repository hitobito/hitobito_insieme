# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::ParticipationsController do
  let(:event) { events(:top_course) }
  let(:role)  { roles(:regio_leader) }
  let(:person) { role.person }

  before { sign_in(role.person) }

  it 'POST#create updates person attributes' do
    expect do
      post :create, group_id: event.groups.first.id, event_id: event.id,
        event_participation: {
          person_attributes: { id: person.id,
                               canton: 'Be',
                               birthday: '2014-09-22',
                               zip_code: 123,
                               town: 'dummy',
                               address: 'dummy',
                               country: 'dummy',
                               correspondence_course_same_as_main: false,
                               correspondence_course_full_name: 'dummy',
                               correspondence_course_company_name: 'dummy',
                               correspondence_course_company: '1',
                               correspondence_course_address: 'dummy',
                               correspondence_course_zip_code: '123',
                               correspondence_course_town: 'dummy',
                               correspondence_course_country: 'dummy',
                               billing_course_same_as_main: '0',
                               billing_course_full_name: 'dummy',
                               billing_course_company_name: 'dummy',
                               billing_course_company: '1',
                               billing_course_address: 'dummy',
                               billing_course_zip_code: '123',
                               billing_course_town: 'dummy',
                               billing_course_country: 'dummy' } }

    end.to change { Event::Participation.count }.by(1)

    person.reload.canton.should eq 'be'
    person.birthday.should eq Date.parse('2014-09-22')

    %w(zip_code billing_course_zip_code correspondence_course_zip_code).each do |attr|
      person.send(attr.to_sym).should eq 123
    end

    %w(correspondence_course_company billing_course_company).each do |attr|
      person.send(attr.to_sym).should be_true
    end

    %w(town address country correspondence_course_full_name correspondence_course_company_name
       correspondence_course_address correspondence_course_town correspondence_course_country
       billing_course_full_name billing_course_company_name  billing_course_address
       billing_course_town billing_course_country).each do |attr|
      person.send(attr.to_sym).should eq 'dummy'
    end
  end

  it 'POST#create does not allow to update different person' do
    expect do
      post :create, group_id: event.groups.first.id, event_id: event.id,
        event_participation: { person_attributes: { id: people(:top_leader).id, canton: 'Bern' }  }
    end.to raise_error ActiveRecord::RecordNotFound
  end

  it 'POST#create does not allow creation of person' do
    expect do
      post :create, group_id: event.groups.first.id, event_id: event.id,
        event_participation: { person_attributes: { canton: 'Bern' }  }
    end.not_to change { Person.count }
  end

  it 'PUT#update does not allow to update different person' do
    participation = Fabricate(:event_participation, event: event)
    expect do
      put :update, group_id: event.groups.first.id, event_id: event.id, id: participation.id,
        event_participation: { person_attributes: { id: people(:top_leader).id, canton: 'Bern' }  }
    end.to raise_error ActiveRecord::RecordNotFound
  end

  context 'grouped_active_membership_roles' do
    let(:participation) { Fabricate(:event_participation, person: person, event: event) }

    it 'should load before show' do
      expect(subject).to receive(:load_grouped_active_membership_roles)
      get :show, group_id: event.groups.first.id, event_id: event.id, id: participation.id
    end

    it 'should only include Group::Aktivmitglieder' do
      Fabricate(Group::Dachverein::Geschaeftsfuehrung.name.to_sym, person: person,
                                                                   group: groups(:dachverein))
      Fabricate(Group::Regionalverein::Praesident.name.to_sym, person: person,
                                                               group: groups(:seeland))
      active = Fabricate(Group::Aktivmitglieder::Aktivmitglied.name.to_sym, person: person,
                                                                            group: groups(:aktiv))

      get :show, group_id: event.groups.first.id, event_id: event.id, id: participation.id
      assigns(:grouped_active_membership_roles).should eq(active.group => [active])
    end
  end
end
