# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CourseReporting::CourseNumbers do

  let(:event) { events(:top_course) }

  subject { CourseReporting::CourseNumbers.new(event) }


  context 'duration days' do
    it 'is correct for whole days' do
      subject.duration_days.should eq(9)
    end
  end

  context 'duration hours' do
    it 'is correct for whole days' do
      subject.duration_hours.should eq(7*24)
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

end
