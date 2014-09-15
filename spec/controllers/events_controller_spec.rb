require 'spec_helper'

describe EventsController do


  before { sign_in(people(:top_leader)) }

  context 'POST#create' do
    let(:group) { groups(:dachverein) }
    let(:date)  {{ label: 'foo', start_at_date: Date.today, finish_at_date: Date.today }}

    let(:course_attrs) { { group_ids: [group.id],
                           name: 'foo',
                           dates_attributes: [date],
                           type: 'Event::Course' } }

    it 'creates new course with leistungskategorie' do
      expect { create('bk') }.to change { Event::Course.count }.by(1)
      assigns(:event).leistungskategorie.should eq 'bk'
    end

    it 'validates leistungskategorie presence' do
      expect { create }.not_to change { Event::Course.count }
      assigns(:event).should have(1).error_on(:leistungskategorie)
    end

    it 'validates leistungskategorie value' do
      expect { create('test') }.not_to change { Event::Course.count }
      assigns(:event).should have(1).error_on(:leistungskategorie)
    end

    def create(leistungskategorie = nil)
      post :create, group_id: group.id, event: course_attrs.merge(leistungskategorie: leistungskategorie)
    end
  end

  context 'PUT#update' do
    it 'ignores chanages to leistungskategorie' do
      put :update, group_id: groups(:be).id, id: events(:top_course).id,
        event: { leistungskategorie: 'sk' }

      events(:top_course).leistungskategorie.should eq 'bk'
    end
  end

end
