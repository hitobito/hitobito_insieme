# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CourseReporting::CourseNumbers do

  let(:event) { events(:top_course) }
  let!(:record) { event.build_course_record }

  subject { CourseReporting::CourseNumbers.new(event) }


  context 'duration days' do
    it 'is correct for whole days' do
      subject.duration_days.should eq(9)
    end
  end

  context 'role counts' do

    context '#challenged_count' do
      it 'is correct' do
        subject.challenged_count.should eq(1)
      end
    end

    context '#affiliated_count' do
      it 'is correct' do
        subject.affiliated_count.should eq(0)
      end

      it 'is correct with duplicate roles' do
        Fabricate(Event::Course::Role::Affiliated.name.to_sym,
                  participation: event_participations(:top_participant))
        subject.affiliated_count.should eq(0)
      end
    end

    context '#participant_count' do
      before do
        Fabricate(Event::Course::Role::Affiliated.name.to_sym,
                  participation: Fabricate(:event_participation, event: event))
      end

      it 'is correct' do
        subject.participant_count.should eq(2)
      end

      it 'is correct with duplicate roles' do
        Fabricate(Event::Course::Role::Affiliated.name.to_sym,
                  participation: event_participations(:top_participant))
        subject.participant_count.should eq(2)
      end
    end

    context '#leader_count' do
      it 'is correct' do
        subject.leader_count.should eq(1)
      end
    end

    context '#expert_count' do
      before do
        Fabricate(Event::Course::Role::Expert.name.to_sym,
                  participation: Fabricate(:event_participation, event: event))
      end

      it 'is correct' do
        subject.expert_count.should eq(1)
      end

      it 'is correct with duplicate lower roles' do
        Fabricate(Event::Course::Role::Expert.name.to_sym,
                  participation: event_participations(:top_participant))
        subject.expert_count.should eq(2)
      end

      it 'is correct with duplicate higher roles' do
        Fabricate(Event::Course::Role::Expert.name.to_sym,
                  participation: event_participations(:top_leader))
        subject.expert_count.should eq(1)
      end
    end

    context '#team_count' do
      it 'is correct' do
        subject.team_count.should eq(1)
      end
    end
  end

  context 'present record values' do
    before do
      record.kursdauer = 5
      record.teilnehmende_behinderte = 5
      record.teilnehmende_angehoerige = 4
      record.teilnehmende_weitere = 1
      record.leiterinnen = 3
      record.fachpersonen = 1
      record.hilfspersonal_mit_honorar = 2
      record.absenzen_behinderte = 2
      record.absenzen_weitere = 1
    end

    context '#presence_percent' do
      it 'is correct' do
        subject.presence_percent.should eq(94)
      end
    end

    context '#challenged_days' do
      it 'is correct' do
        subject.challenged_days.should eq(23)
      end
    end

    context '#affiliated_days' do
      it 'is correct' do
        subject.affiliated_days.should eq(20)
      end
    end

    context '#not_entitled_for_benefit_days' do
      it 'is correct' do
        subject.not_entitled_for_benefit_days.should eq(4)
      end
    end

    context '#participant_days' do
      it 'is correct' do
        subject.participant_days.should eq(47)
      end
    end

    context '#mentoring_ratio' do
      it 'is correct' do
        subject.mentoring_ratio.should eq(5.to_d/6.to_d)
      end
    end

  end

  context 'blank record values' do
    context '#presence_percent' do
      it 'is correct' do
        subject.presence_percent.should eq(100)
      end
    end

    context '#challenged_days' do
      it 'is correct' do
        subject.challenged_days.should eq(0)
      end
    end

    context '#affiliated_days' do
      it 'is correct' do
        subject.affiliated_days.should eq(0)
      end
    end

    context '#not_entitled_for_benefit_days' do
      it 'is correct' do
        subject.not_entitled_for_benefit_days.should eq(0)
      end
    end

    context '#participant_days' do
      it 'is correct' do
        subject.participant_days.should eq(0)
      end
    end

    context '#mentoring_ratio' do
      it 'is correct' do
        subject.mentoring_ratio.should eq(0.to_d)
      end
    end
  end
end
