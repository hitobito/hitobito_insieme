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

          expect(assigns(:person)).to be_valid
          expect(person.reload.number).to eq 2
          expect(person.reload.reference_person_number).to eq 3
        end
      end

      context 'by person itself' do
        it 'won\'t be updated' do
          put :update, group_id: group.id,
                       id: person.id,
                       person: { number: 2,
                                 manual_number: '1',
                                 reference_person_number: '3' }

          expect(assigns(:person)).to be_valid
          expect(person.reload.number).not_to eq 2
          expect(person.number).to eq Person::AUTOMATIC_NUMBER_RANGE.first
          expect(person.reference_person_number).to be_nil
        end
      end
    end

    it 'generates automatic number' do
      put :update, group_id: group.id,
                   id: person.id,
                   person: { number: 2,
                             manual_number: 0 }

      expect(assigns(:person)).to be_valid
      expect(person.reload.number).to eq Person::AUTOMATIC_NUMBER_RANGE.first
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

          expect(assigns(:person)).to be_valid
          expect(person.reload.dossier).to eq 'http://en.wikipedia.org/wiki/James_Dean'
        end
      end

      context 'by person itself' do
        it 'won\'t be updated' do
          put :update, group_id: group.id,
                       id: person.id,
                       person: { dossier: 'http://en.wikipedia.org/wiki/James_Dean' }

          expect(assigns(:person)).to be_valid
          expect(person.reload.dossier).to be_nil
        end
      end

    end

    context 'ahv_number' do
      it 'will be updated' do
        put :update, group_id: group.id,
                     id: person.id,
                     person: { ahv_number: '123456789' }
        expect(assigns(:person)).to be_valid
        expect(person.reload.ahv_number).to eq '123456789'
      end
    end
  end



  context 'GET index' do
    before { sign_in(person) }

    it 'exports salutation, number and correspondence_language' do
      get :index, group_id: group, format: :csv

      expect(@response.body).to match(/.*Personnr\.;Anrede;Korrespondenzsprache.*/)
    end
  end

  context 'GET query' do
    before { sign_in(person) }

    it 'searches number as well' do
      people(:top_leader).update!(number: 107)
      people(:regio_aktiv).update!(number: 10107)
      people(:regio_leader).update!(number: 10007)
      get :query, q: '107', format: :json

      expect(@response.body).to match(/107 Top Leader/)
      expect(@response.body).to match(/10107 Active Person/)
      expect(@response.body).not_to match(/Flock Leader/)
    end
  end
end
