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

    context 'layer_and_below_full' do
      it 'is allowed to update course record of regionalverein' do
        get :edit, group_id: group.id, event_id: event.id
        expect(response).to be_ok
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
        expect(response).to be_ok
      end
    end

    context 'course participant with controlling role on group' do
      let(:role) do
        role = Fabricate(Group::Regionalverein::Controlling.name.to_sym, group: group)
        Fabricate(Event::Role::Participant.name.to_sym,
                  participation: Fabricate(:event_participation,
                                           event: event, person: role.person))
        role
      end

      it 'is allowed to update course record of regionalverein' do
        get :edit, group_id: group.id, event_id: event.id
        expect(response).to be_ok
      end
    end

    context 'course participant' do
      let(:role) do
        role = Fabricate(Group::Regionalverein::Versandadresse.name.to_sym, group: group)
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
      expect(response.status).to eq(200)

      expect(assigns(:course_record)).not_to be_persisted
      expect(assigns(:course_record).event).to eq event
    end

    it 'assigns default values' do
      get :edit, group_id: group.id, event_id: event.id

      expect(assigns(:course_record).inputkriterien).to eq 'a'
      expect(assigns(:course_record).kursart).to eq 'weiterbildung'
      expect(assigns(:course_record).subventioniert).to eq true
      expect(assigns(:course_record).spezielle_unterkunft).to be_nil
    end

    it 'reuses existing course_record based on group and event' do
      record = Event::CourseRecord.create!(event: event,
                                           inputkriterien: 'a',
                                           kursart: 'weiterbildung')

      get :edit, group_id: group.id, event_id: event.id
      expect(response.status).to eq(200)

      expect(assigns(:course_record)).to eq record
      expect(assigns(:course_record).event).to eq event
      expect(assigns(:course_record)).to be_persisted
    end


    context 'decimals for sk', db: :mysql do
      render_views

      let(:event) { Fabricate(:course, groups: [group], leistungskategorie: 'sk') }
      let(:field) { dom.find('#event_course_record_kursdauer') }
      let(:dom) { Capybara::Node::Simple.new(response.body) }

      before { event.create_course_record!(kursdauer: 1) }

      it 'it renders 1.0 as 1' do
        get :edit, group_id: group.id, event_id: event.id
        expect(field.value).to eq '1'
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
        teilnehmende_mehrfachbehinderte: 3,
        challenged_canton_count_attributes: { 'be' => 1, 'zh' => 2, 'other' => 3 },
        affiliated_canton_count_attributes: { 'ag' => 4, 'ge' => 5 },
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
        unless key.to_s =~ /_attributes$/
          expect(event.course_record.send(key)).to eq value
        end
      end

      expect(event.course_record.challenged_canton_count).to be_a(Event::ParticipationCantonCount)
      expect(event.course_record.challenged_canton_count.be).to eq(1)
      expect(event.course_record.challenged_canton_count.zh).to eq(2)
      expect(event.course_record.challenged_canton_count.other).to eq(3)

      expect(event.course_record.affiliated_canton_count).to be_a(Event::ParticipationCantonCount)
      expect(event.course_record.affiliated_canton_count.ag).to eq(4)
      expect(event.course_record.affiliated_canton_count.ge).to eq(5)
    end
  end
end
