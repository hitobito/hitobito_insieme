# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::CourseRecordsController do
  let(:group) { groups(:be) }
  let(:event) { events(:top_course) }
  let(:role)  { roles(:regio_leader) }

  before { sign_in(role.person) }

  context 'authorization' do
    context 'simple event (not course)' do
      it 'not found' do
        simple_event = Fabricate(:event, groups: [group])

        expect do
          get :edit, group_id: group.id, event_id: simple_event.id
        end.to raise_error(ActionController::RoutingError)
      end
    end

    context :layer_and_below_full do
      it 'is allowed to update course record of regionalverein' do
        get :edit, group_id: group.id, event_id: event.id
        response.should be_ok
      end
    end

    context 'course leader' do
      let(:role) do
        role = Fabricate(Group::Regionalverein::Controlling.name.to_sym, group: group)
        participation = Fabricate(:event_participation, event: event, person: role.person)
        Event::Course::Role::LeaderAdmin.create!(participation: participation)
        role
      end

      it 'is allowed to update course record of regionalverein' do
        get :edit, group_id: group.id, event_id: event.id
        response.should be_ok
      end
    end

    context 'course participant' do
      let(:role) do
        role = Fabricate(Group::Regionalverein::Controlling.name.to_sym, group: group)
        Fabricate(Event::Role::Participant.name.to_sym,
                  participation: Fabricate(:event_participation,
                                           event: event, person: role.person))
        role
      end

      it 'is not allowed to update course record of regionalverein' do
        expect do
          get :edit, group_id: group.id, event_id: event.id
        end.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  context '#edit' do
    it 'builds new course_record based on group and event' do
      get :edit, group_id: group.id, event_id: event.id
      response.status.should eq(200)

      assigns(:course_record).should_not be_persisted
      assigns(:course_record).event.should eq event
    end

    it 'assigns default values' do
      get :edit, group_id: group.id, event_id: event.id

      assigns(:course_record).inputkriterien.should eq 'a'
      assigns(:course_record).kursart.should eq 'weiterbildung'
      assigns(:course_record).subventioniert.should eq true
      assigns(:course_record).spezielle_unterkunft.should be_nil
    end

    it 'reuses existing course_record based on group and event' do
      record = Event::CourseRecord.create!(event: event,
                                           inputkriterien: 'a',
                                           kursart: 'weiterbildung')

      get :edit, group_id: group.id, event_id: event.id
      response.status.should eq(200)

      assigns(:course_record).should eq record
      assigns(:course_record).event.should eq event
      assigns(:course_record).should be_persisted
    end


    context 'decimals for sk', db: :mysql do
      render_views

      let(:event) { Fabricate(:course, groups: [group], leistungskategorie: 'sk') }
      let(:field) { dom.find('#event_course_record_kursdauer') }
      let(:dom) { Capybara::Node::Simple.new(response.body) }

      before { event.create_course_record!(kursdauer: 1) }

      it 'it renders 1.0 as 1' do
        get :edit, group_id: group.id, event_id: event.id
        field.value.should eq '1'
      end

    end
  end

  context '#update' do
    let(:attrs) do
      { subventioniert: true,
        inputkriterien: 'a',
        kursart: 'weiterbildung',
        spezielle_unterkunft: false,
        kursdauer: 10,
        teilnehmende_behinderte: 10,
        teilnehmende_mehrfachbehinderte: 10,
        teilnehmende_angehoerige: 10,
        teilnehmende_weitere: 10,
        absenzen_behinderte: 10,
        absenzen_angehoerige: 10,
        absenzen_weitere: 10,
        leiterinnen: 10,
        fachpersonen: 10,
        hilfspersonal_ohne_honorar: 10,
        hilfspersonal_mit_honorar: 10,
        kuechenpersonal: 10,
        honorare_inkl_sozialversicherung: 10,
        unterkunft: 10,
        uebriges: 10,
        beitraege_teilnehmende: 10 }
    end

    it 'assigns all permitted params' do
      expect do
        put :update, group_id: group.id, event_id: event.id, event_course_record: attrs
      end.to change { Event::CourseRecord.count }.by(1)

      attrs.each do |key, value|
        event.course_record.send(key).should eq value
      end
    end
  end
end
