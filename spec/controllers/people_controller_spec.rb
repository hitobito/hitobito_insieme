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

  context 'PUT udpate' do
    before { sign_in(person) }

    it 'saves manual numbers' do
      put :update,
          group_id: group.id,
          id: person.id,
          person: { number: 2,
                    manual_number: '1' }

      assigns(:person).should be_valid
      person.reload.number.should eq 2
    end

    it 'generates automatic numbers' do
      put :update,
          group_id: group.id,
          id: person.id,
          person: { number: 2,
                    manual_number: 0 }

      assigns(:person).should be_valid
      person.reload.number.should eq Person::AUTOMATIC_NUMBER_RANGE.first
    end
  end



  context 'GET index' do
    before { sign_in(person) }

    it 'exports salutation and number' do
      get :index, group_id: group, format: :csv

      @response.body.should =~ /.*Personnr\.;Anrede;.*/
    end
  end

end
