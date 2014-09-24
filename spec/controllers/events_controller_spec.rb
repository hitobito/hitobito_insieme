require 'spec_helper'

describe EventsController do


  before { sign_in(people(:top_leader)) }

  context 'GET#new' do
    let(:group) { groups(:dachverein) }

    it 'sets defaults for course record' do
      get :new, group_id: group.id, event: { type: 'Event::Course' }

      assigns(:event).course_record.kursart.should eq 'weiterbildung'
      assigns(:event).course_record.inputkriterien.should eq 'a'
      assigns(:event).course_record.should be_subventioniert
    end
  end

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

    context 'nested course_record fields' do
      it 'creates course record attribute' do
        expect { create('bk') }.to change { Event::CourseRecord.count }.by(1)
      end

      it 'validates course record attributes' do
        expect { create('bk', { inputkriterien: 'b', subventioniert: 0 }) }.not_to change { Event::CourseRecord.count }
        assigns(:event).errors.keys.should eq [:"course_record.inputkriterien"] # how to do this with error_on?
      end
    end

    def create(leistungskategorie = nil, course_record_attributes = {})
      post :create, group_id: group.id, event: course_attrs.merge(leistungskategorie: leistungskategorie,
                                                                  course_record_attributes: course_record_attributes)
    end
  end

  context 'PUT#update' do
    let(:event) { events(:top_course) }

    it 'ignores changes to leistungskategorie' do
      put :update, group_id: groups(:be).id, id: event.id,
        event: { leistungskategorie: 'sk' }

      event.leistungskategorie.should eq 'bk'
    end

    context 'nested course_record fields' do
      before { event.create_course_record! }

      it 'updates course record attribute' do
        update(inputkriterien: 'b')
        assigns(:event).course_record.inputkriterien.should eq 'b'
      end

      it 'validates course record attributes' do
        update(inputkriterien: 'b', subventioniert: 0)
        assigns(:event).errors.keys.should eq [:"course_record.inputkriterien"]
      end

      it 'only updates, does not change missing fields' do
        event.course_record.update_attribute(:kursdauer, 1)
        update(id: event.course_record.id, inputkriterien: 'b')

        event.reload.course_record.kursdauer.should eq 1
      end

      it 'raises not_found when trying to update different course_record' do
        other = Fabricate(:course, groups: [groups(:be)], leistungskategorie: 'sk', course_record_attributes: { kursdauer: 10 } )
        expect { update(id: other.course_record.id, kursdauer: 1) }.to raise_error ActiveRecord::RecordNotFound
      end

      def update(course_record_attributes = {})
        put :update, group_id: event.groups.first.id, id: event.id, event: { course_record_attributes: course_record_attributes }
      end
    end
  end

end
