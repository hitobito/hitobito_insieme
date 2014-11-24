# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe PeopleController do
  it 'should permit the prefixed address attributes' do
    expect(PeopleController.permitted_attrs).to include(:correspondence_general_first_name)
    expect(PeopleController.permitted_attrs).to include(:billing_general_first_name)
    expect(PeopleController.permitted_attrs).to include(:correspondence_course_first_name)
    expect(PeopleController.permitted_attrs).to include(:billing_course_first_name)
    expect(PeopleController.permitted_attrs).to include(:correspondence_general_company_name)
  end

  let(:group)  { groups(:dachverein) }
  let(:person) { people(:top_leader) }

  context 'PUT update' do
    before { sign_in(person) }

    context 'manual number and reference_person_number' do
      context 'by another person' do
        let(:other_person) do
          Fabricate(Group::Dachverein::Geschaeftsfuehrung.sti_name.to_sym, group: group).person
        end
        before { sign_in(other_person) }

        it 'will be updated' do
          put :update, group_id: group.id,
                       id: person.id,
                       person: { number: 2,
                                 manual_number: '1',
                                 reference_person_number: '3' }

          assigns(:person).should be_valid
          person.reload.number.should eq 2
          person.reload.reference_person_number.should eq 3
        end
      end

      context 'by person itself' do
        it 'won\'t be updated' do
          put :update, group_id: group.id,
                       id: person.id,
                       person: { number: 2,
                                 manual_number: '1',
                                 reference_person_number: '3' }

          assigns(:person).should be_valid
          person.reload.number.should_not eq 2
          person.number.should eq Person::AUTOMATIC_NUMBER_RANGE.first
          person.reference_person_number.should be_nil
        end
      end
    end

    it 'generates automatic number' do
      put :update, group_id: group.id,
                   id: person.id,
                   person: { number: 2,
                             manual_number: 0 }

      assigns(:person).should be_valid
      person.reload.number.should eq Person::AUTOMATIC_NUMBER_RANGE.first
    end

    context 'dossier' do
      context 'by another person' do
        let(:other_person) do
          Fabricate(Group::Dachverein::Geschaeftsfuehrung.sti_name.to_sym, group: group).person
        end
        before { sign_in(other_person) }

        it 'will be updated' do
          put :update, group_id: group.id,
                       id: person.id,
                       person: { dossier: 'http://en.wikipedia.org/wiki/James_Dean' }

          assigns(:person).should be_valid
          person.reload.dossier.should eq 'http://en.wikipedia.org/wiki/James_Dean'
        end
      end

      context 'by person itself' do
        it 'won\'t be updated' do
          put :update, group_id: group.id,
                       id: person.id,
                       person: { dossier: 'http://en.wikipedia.org/wiki/James_Dean' }

          assigns(:person).should be_valid
          person.reload.dossier.should be_nil
        end
      end

    end

    context 'ahv_number' do
      it 'will be updated' do
        put :update, group_id: group.id,
                     id: person.id,
                     person: { ahv_number: '123456789' }
        assigns(:person).should be_valid
        person.reload.ahv_number.should eq '123456789'
      end
    end
  end



  context 'GET index' do
    before { sign_in(person) }

    it 'exports salutation, number and correspondence_language' do
      get :index, group_id: group, format: :csv

      @response.body.should =~ /.*Personnr\.;Anrede;Korrespondenzsprache.*/
    end
  end

  context 'GET query' do
    before { sign_in(person) }

    it 'searches number as well' do
      people(:top_leader).update!(number: 107)
      people(:regio_aktiv).update!(number: 10107)
      people(:regio_leader).update!(number: 10007)
      get :query, q: '107', format: :json

      @response.body.should =~ /107 Top Leader/
      @response.body.should =~ /10107 Active Person/
      @response.body.should_not =~ /Flock Leader/
    end
  end
end
