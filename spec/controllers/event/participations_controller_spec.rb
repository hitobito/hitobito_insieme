# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'
require 'csv'

describe Event::ParticipationsController do
  let(:event) { events(:top_course) }
  let(:role)  { roles(:regio_leader) }
  let(:person) { role.person }

  before { sign_in(role.person) }

  it 'POST create updates person attributes' do
    expect do
      post :create, params: { group_id: event.groups.first.id, event_id: event.id, event_participation: {
          person_attributes: { id: person.id,
                               canton: 'Be',
                               birthday: '2014-09-22',
                               zip_code: '1234',
                               town: 'dummy',
                               address: 'dummy',
                               country: 'DE',
                               ahv_number: '123',
                               correspondence_course_same_as_main: false,
                               correspondence_course_salutation: 'dummy',
                               correspondence_course_first_name: 'dummy',
                               correspondence_course_last_name: 'dummy',
                               correspondence_course_company_name: 'dummy',
                               correspondence_course_company: '1',
                               correspondence_course_address: 'dummy',
                               correspondence_course_zip_code: '1234',
                               correspondence_course_town: 'dummy',
                               correspondence_course_country: 'DE',
                               billing_course_same_as_main: '0',
                               billing_course_salutation: 'dummy',
                               billing_course_first_name: 'dummy',
                               billing_course_last_name: 'dummy',
                               billing_course_company_name: 'dummy',
                               billing_course_company: '1',
                               billing_course_address: 'dummy',
                               billing_course_zip_code: '1234',
                               billing_course_town: 'dummy',
                               billing_course_country: 'DE' } } }

    end.to change { Event::Participation.count }.by(1)


    expect(person.reload.canton).to eq 'be'
    expect(person.birthday).to eq Date.parse('2014-09-22')
    expect(person.ahv_number).to eq '123'
    expect(person.zip_code).to eq '1234'

    %w(billing_course_zip_code correspondence_course_zip_code).each do |attr|
      expect(person.send(attr.to_sym)).to eq 1234
    end

    %w(correspondence_course_company billing_course_company).each do |attr|
      expect(person.send(attr.to_sym)).to be_truthy
    end

    %w(town
       address

       correspondence_course_salutation
       correspondence_course_first_name
       correspondence_course_last_name
       correspondence_course_company_name
       correspondence_course_address
       correspondence_course_town

       billing_course_salutation
       billing_course_first_name
       billing_course_last_name
       billing_course_company_name
       billing_course_address
       billing_course_town).each do |attr|
      expect(person.send(attr.to_sym)).to eq 'dummy'
    end
    expect(person.country).to eq 'DE'
    expect(person.correspondence_course_country).to eq 'DE'
    expect(person.billing_course_country).to eq 'DE'
  end

  it 'POST create does not allow to update different person' do
    expect do
      post :create,
           params: {
             group_id: event.groups.first.id,
             event_id: event.id,
             event_participation: { person_attributes: { id: people(:top_leader).id, canton: 'Bern' }  }
           }
    end.to raise_error ActiveRecord::RecordNotFound
  end

  it 'POST create does not allow creation of person' do
    expect do
      post :create,
           params: {
             group_id: event.groups.first.id,
             event_id: event.id,
             event_participation: { person_attributes: { canton: 'Bern' }  }
           }
    end.not_to change { Person.count }
  end

  it 'PUT update does not allow to update different person' do
    participation = Fabricate(:event_participation, event: event)
    expect do
      put :update,
          params: {
            group_id: event.groups.first.id,
            event_id: event.id,
            id: participation.id,
            event_participation: { person_attributes: { id: people(:top_leader).id, canton: 'Bern' }  }
          }
    end.to raise_error ActiveRecord::RecordNotFound
  end

  it 'PUT update changes participation fields' do
    participation = Fabricate(:event_participation, event: event)
    put :update,
        params: {
          group_id: event.groups.first.id,
          event_id: event.id,
          id: participation.id,
          event_participation: {
            wheel_chair: false,
            multiple_disability: true,
            disability: 'seh' }
        }

    participation.reload
    expect(participation.wheel_chair).to be false
    expect(participation.disability).to eq 'seh'
    expect(participation.multiple_disability).to be true
  end

  context 'internal fields' do
    let(:csv) { CSV.parse(Delayed::Job.last.payload_object.send(:data), headers: true, col_sep: ';') }
    let(:internal_fields) { { invoice_text: 'test', invoice_amount: '1.2' } }

    let(:group) { groups(:be) }
    let(:course) { Fabricate(:course, groups: [group], leistungskategorie: 'bk', fachkonzept: 'sport_jugend') }

    before do
      course.update_attribute(:state, :application_open)
      sign_in(person)
    end

    def activate_participation
      participation.roles << Fabricate(:event_role, type: Event::Course::Role::LeaderBasic.name)
      participation.update(active: true,
                                      disability: 'hoer',
                                      multiple_disability: nil,
                                      wheel_chair: true,
                                      invoice_text: 'test',
                                      invoice_amount: 1.2)
    end

    [
      { permission: ':layer_full',
        group_role: Group::Regionalverein::Geschaeftsfuehrung,
        group_name: :be,
        course_role: Event::Course::Role::LeaderBasic },
      { permission: ':participations_full',
        group_role: Group::Dachverein::Geschaeftsfuehrung,
        group_name: :dachverein,
        course_role: Event::Course::Role::LeaderAdmin }
    ].each do |attrs|
      context "with #{attrs[:permission]} permission" do
        let(:person) do
          Fabricate(attrs[:group_role].name.to_sym, group: groups(attrs[:group_name])).person
        end
        let(:participation) do
          p = Fabricate(:event_participation, event: course, person: person, active: true)
          p.roles << Fabricate(:event_role, type: attrs[:course_role].name)
          p
        end

        if attrs[:permission] != ':participations_full'
          it 'updates attributes on create' do
            post :create, params: { group_id: group.id, event_id: course.id, event_participation: internal_fields }
            expect(assigns(:participation).invoice_text).to eq 'test'
            expect(assigns(:participation).invoice_amount).to eq 1.2
          end
        end

        it 'updates attributes on update' do
          patch :update, params: { group_id: group.id, event_id: course.id, id: participation.id, event_participation: internal_fields }
          expect(participation.reload.invoice_text).to eq 'test'
          expect(participation.reload.invoice_amount).to eq 1.2
        end

        it 'includes attributes in csv' do
          activate_participation
          get :index, params: {
                        group_id: group.id,
                        event_id: course.id,
                        filter: 'teamers',
                        details: true
                      },
                      format: :csv

          expect(response).to redirect_to group_event_participations_path(group, course, returning: true)
          expect(csv['Rollstuhl']).to eq %w(ja)
          expect(csv['Behinderung']).to eq %w(Hörbehindert)
          expect(csv['Mehrfachbehinderung']).to eq [nil]
          expect(csv['Rechnungstext']).to eq %w(test)
          expect(csv['Rechnungsbetrag']).to eq %w(1.2)
        end

        context 'rendered pages' do
          render_views
          before { activate_participation }

          it 'includes attributes on show' do
            get :show, params: { group_id: group.id, event_id: course.id, id: participation.id }
          end

          it 'includes attributes on edit' do
            get :edit, params: { group_id: group.id, event_id: course.id, id: participation.id }
          end

          after do
            html = Capybara::Node::Simple.new(response.body)
            expect(html).to have_content 'Rechnungstext'
            expect(html).to have_content 'Rechnungsbetrag'
          end
        end
      end
    end


    context 'without :layer_full or :participations_full permission' do
      let(:person) do
        Fabricate(Group::Dachverein::Geschaeftsfuehrung.name.to_sym,
                  group: groups(:dachverein)).person
      end
      let(:participation) { Fabricate(:event_participation, event: course, person: person) }

      it 'ignores attributes on create' do
        post :create, params: { group_id: group.id, event_id: course.id, event_participation: internal_fields }
        expect(assigns(:participation).invoice_text).to be_blank
        expect(assigns(:participation).invoice_amount).to be_nil
      end

      it 'ignores attributes on update' do
        patch :update, params: { group_id: group.id, event_id: course.id, id: participation.id, event_participation: internal_fields }
        expect(assigns(:participation).invoice_text).to be_blank
        expect(assigns(:participation).invoice_amount).to be_nil
      end

      it 'does not include attributes in csv' do
        activate_participation
        get :index, params: { group_id: group.id, event_id: course.id, filter: :participants }, format: :csv

        expect(csv.headers).not_to include 'Behinderung'
        expect(csv.headers).not_to include 'Mehrfachbehindert'
        expect(csv.headers).not_to include 'Rollstuhl'
        expect(csv.headers).not_to include 'Rechnungstext'
        expect(csv.headers).not_to include 'Rechnungsbetrag'
      end

      context 'rendered pages' do
        render_views
        before { activate_participation }

        it 'does not include attributes on show' do
          get :show, params: { group_id: group.id, event_id: course.id, id: participation.id }
        end

        it 'does not render edit page' do
          get :edit, params: { group_id: group.id, event_id: course.id, id: participation.id }
        end

        after do
          html = Capybara::Node::Simple.new(response.body)
          expect(html).not_to have_content 'Rechnungstext'
          expect(html).not_to have_content 'Rechnungsbetrag'
        end
      end

    end
  end
end
