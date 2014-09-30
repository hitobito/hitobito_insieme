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
                               canton: 'Bern',
                               birthday: '2014-09-22',
                               zip_code: 123,
                               town: 'dummy',
                               address: 'dummy',
                               country: 'dummy',
                               correspondence_course_full_name: 'dummy',
                               correspondence_course_company_name: 'dummy',
                               correspondence_course_company: '1',
                               correspondence_course_address: 'dummy',
                               correspondence_course_zip_code: '123',
                               correspondence_course_town: 'dummy',
                               correspondence_course_country: 'dummy',
                               billing_course_full_name: 'dummy',
                               billing_course_company_name: 'dummy',
                               billing_course_company: '1',
                               billing_course_address: 'dummy',
                               billing_course_zip_code: '123',
                               billing_course_town: 'dummy',
                               billing_course_country: 'dummy' } }

    end.to change { Event::Participation.count }.by(1)

    person.reload.canton.should eq 'Bern'
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

end
