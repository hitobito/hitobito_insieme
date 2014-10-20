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

  context 'internal fields' do
    let(:csv) { CSV.parse(response.body, headers: true, col_sep: ';') }
    let(:internal_fields) { { internal_invoice_text: 'test', internal_invoice_amount: '1.2' } }

    let(:group) { groups(:be) }
    let(:course) { Fabricate(:course, groups: [group], leistungskategorie: 'bk') }

    before do
      course.update_attribute(:state, :application_open)
      sign_in(person)
    end

    def activate_participation
      participation.roles << Fabricate(:event_role, type: Event::Course::Role::LeaderBasic.name)
      participation.update_attributes(active: true,
                                      internal_invoice_text: 'test',
                                      internal_invoice_amount: 1.2)
    end

    [
      { permission: ':layer_full', group_role: Group::Regionalverein::Geschaeftsfuehrung,
        group_name: :be, course_role: Event::Course::Role::LeaderBasic },
      { permission: ':participations_full', group_role: Group::Dachverein::Geschaeftsfuehrung,
        group_name: :dachverein, course_role: Event::Course::Role::LeaderAdmin }
    ].each do |attrs|
      context "with #{attrs[:permission]} permission" do
        let(:person) do
          Fabricate(attrs[:group_role].name.to_sym, group: groups(attrs[:group_name])).person
        end
        let(:participation) do
          p = Fabricate(:event_participation, event: course, person: person)
          p.roles << Fabricate(:event_role, type: attrs[:course_role].name)
          p
        end

        if attrs[:permission] != ':participations_full'
          it 'updates attributes on create' do
            post :create, group_id: group.id, event_id: course.id,
            event_participation: internal_fields
            assigns(:participation).internal_invoice_text.should eq 'test'
            assigns(:participation).internal_invoice_amount.should eq 1.2
          end
        end

        it 'updates attributes on update' do
          patch :update, group_id: group.id, event_id: course.id, id: participation.id,
                         event_participation: internal_fields
          participation.reload.internal_invoice_text.should eq 'test'
          participation.reload.internal_invoice_amount.should eq 1.2
        end

        it 'includes attributes in csv' do
          activate_participation
          get :index, group_id: group.id,
                      event_id: course.id,
                      filter: :participants,
                      details: true,
                      format: :csv
          csv['Rechnungstext'].should eq %w(test)
          csv['Rechnungsbetrag'].should eq %w(1.2)
        end

        context 'rendered pages' do
          render_views
          before { activate_participation }

          it 'includes attributes on show' do
            get :show, group_id: group.id, event_id: course.id, id: participation.id
          end

          it 'includes attributes on edit' do
            get :edit, group_id: group.id, event_id: course.id, id: participation.id
          end

          after do
            html = Capybara::Node::Simple.new(response.body)
            html.should have_content 'Rechnungstext'
            html.should have_content 'Rechnungsbetrag'
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
        post :create, group_id: group.id, event_id: course.id, event_participation: internal_fields
        assigns(:participation).internal_invoice_text.should be_blank
        assigns(:participation).internal_invoice_amount.should be_nil
      end

      it 'ignores attributes on update' do
        patch :update, group_id: group.id, event_id: course.id, id: participation.id,
            event_participation: internal_fields
        assigns(:participation).internal_invoice_text.should be_blank
        assigns(:participation).internal_invoice_amount.should be_nil
      end

      it 'does not include attributes in csv' do
        activate_participation
        get :index, group_id: group.id, event_id: course.id, filter: :participants, format: :csv

        csv.headers.should_not include 'Rechnungstext'
        csv.headers.should_not include 'Rechnungsbetrag'
      end

      context 'rendered pages' do
        render_views
        before { activate_participation }

        it 'does not include attributes on show' do
          get :show, group_id: group.id, event_id: course.id, id: participation.id
        end

        it 'does not render edit page' do
          get :edit, group_id: group.id, event_id: course.id, id: participation.id
        end

        after do
          html = Capybara::Node::Simple.new(response.body)
          html.should_not have_content 'Rechnungstext'
          html.should_not have_content 'Rechnungsbetrag'
        end
      end

    end
  end
end
