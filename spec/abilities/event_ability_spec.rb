# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe EventAbility do

  let(:event)   { events(:top_course) }
  let(:role)    { create_role }
  let(:ability) { Ability.new(role.person.reload) }

  def create_role(event_role_type = role_type)
    participation = Fabricate(:event_participation, person: Fabricate(:person), event: event)
    event_role_type.create!(participation: participation)
  end

  class << self
    def may_execute(*actions)
      may_or_not(actions, :may, :should)
    end

    def may_not_execute(*actions)
      may_or_not(actions, :may, :should_not)
    end

    def may_or_not(actions, text, method)
      actions.each do |action|
        it "#{text} execute #{action}"  do
          ability.send(method, be_able_to(action, model))
        end
      end
    end
  end

  context :read do
    subject { ability }

    context 'layer read and below' do
      let(:role) { Fabricate(Group::Dachverein::Geschaeftsfuehrung.name.to_sym,
                             group: groups(:dachverein)) }

      context 'regular event' do
        context 'in same layer' do
          it { should be_able_to(:read, Fabricate.build(:event, groups: [role.group])) }
        end

        context 'in lower layer' do
          it { should be_able_to(:read, Fabricate.build(:event, groups: [groups(:seeland)])) }
        end
      end

      context 'aggregate course' do
        context 'in same layer' do
          it { should be_able_to(:read, Fabricate.build(:aggregate_course, groups: [role.group])) }
        end

        context 'in lower layer' do
          it { should be_able_to(:read, Fabricate.build(:aggregate_course, groups: [groups(:seeland)])) }
        end
      end
    end

    context 'any role' do
      let(:role) { Fabricate(Group::Regionalverein::Praesident.name.to_sym, group: groups(:be)) }

      context 'regular event' do
        context 'in same layer' do
          it { should be_able_to(:read, Fabricate.build(:event, groups: [role.group])) }
        end

        context 'in upper layer' do
          it { should_not be_able_to(:read, Fabricate.build(:event, groups: [groups(:dachverein)])) }
        end

        context 'in lower non-regionalverein layer' do
          it { should_not be_able_to(:read, Fabricate.build(:event, groups: [groups(:aktiv)])) }
        end

        context 'in lower regionalverein layer' do
          it { should be_able_to(:read, Fabricate.build(:event, groups: [groups(:seeland)])) }
        end

        context 'in other regionalverein layer' do
          it { should be_able_to(:read, Fabricate.build(:event, groups: [groups(:fr)])) }
        end
      end

      context 'aggregate course' do
        context 'in same layer' do
          it { should be_able_to(:read, Fabricate.build(:aggregate_course, groups: [role.group])) }
        end

        context 'in upper layer' do
          it { should_not be_able_to(:read, Fabricate.build(:aggregate_course, groups: [groups(:dachverein)])) }
        end

        context 'in lower non-regionalverein layer' do
          it { should_not be_able_to(:read, Fabricate.build(:aggregate_course, groups: [groups(:aktiv)])) }
        end

        context 'in lower regionalverein layer' do
          it { should_not be_able_to(:read, Fabricate.build(:aggregate_course, groups: [groups(:seeland)])) }
        end

        context 'in other regionalverein layer' do
          it { should_not be_able_to(:read, Fabricate.build(:aggregate_course, groups: [groups(:fr)])) }
        end
      end

      context 'participating event' do
        let(:event) { Fabricate(:event, groups: [groups(:seeland)]) }
        before do
          Fabricate(Event::Role::Participant.name.to_sym,
                    participation: Fabricate(:event_participation,
                                             event: event, person: role.person))
        end
        it { should be_able_to(:read, event) }
      end
    end
  end

  context Event::Course::Role::LeaderAdmin do
    let(:role_type) { Event::Course::Role::LeaderAdmin }

    context 'event' do
      let(:model) { event }
      may_execute(:update, :index_participations, :application_market)
    end

    context 'participation' do
      let(:model) { create_role(Event::Course::Role::Affiliated).participation }
      may_execute(:update, :show, :show_details)
    end

    context 'role' do
      let(:model) { create_role(Event::Course::Role::Affiliated) }
      may_execute(:create, :update, :show, :destroy)
    end

    context 'course_record' do
      let(:model) { event.create_course_record! }
      may_execute(:update)
    end
  end

  context Event::Course::Role::LeaderReporting do
    let(:role_type) { Event::Course::Role::LeaderReporting }

    context 'event' do
      let(:model) { event }
      may_execute(:index_participations)
      may_not_execute(:update, :application_market)
    end

    context 'participation' do
      let(:model) { create_role(Event::Course::Role::Affiliated).participation }
      may_execute(:show)
      may_not_execute(:update, :show_details)
    end

    context 'role' do
      let(:model) { create_role(Event::Course::Role::Affiliated) }
      may_not_execute(:create, :update, :show, :destroy)
    end

    context 'course_record' do
      let(:model) { event.create_course_record! }
      may_execute(:update)
    end
  end


  [Event::Course::Role::LeaderBasic,
   Event::Course::Role::Expert,
   Event::Course::Role::HelperPaid,
   Event::Course::Role::HelperUnpaid].each do |leader_type|
    context leader_type do
      let(:role_type) { leader_type }

      context 'event' do
        let(:model) { event }
        may_execute(:index_participations)
        may_not_execute(:update, :application_market)
      end

      context 'participation' do
        let(:model) { create_role(Event::Course::Role::Affiliated).participation }
        may_execute(:show)
        may_not_execute(:update, :show_details)
      end

      context 'role' do
        let(:model) { create_role(Event::Course::Role::Affiliated) }
        may_not_execute(:create, :update, :show, :destroy)
      end

      context 'course_record' do
        let(:model) { event.create_course_record! }
        may_not_execute(:update)
      end
    end

   end

  context Event::Course::Role::Kitchen do
    let(:role_type) { Event::Course::Role::Kitchen }

    context 'event' do
      let(:model) { event }
      may_not_execute(:index_participations, :update, :application_market)
    end

    context 'participation' do
      let(:model) { create_role(Event::Course::Role::Affiliated).participation }
      may_not_execute(:show, :update, :show_details)
    end

    context 'role' do
      let(:model) { create_role(Event::Course::Role::Affiliated) }
      may_not_execute(:create, :update, :show, :destroy)
    end

    context 'course_record' do
      let(:model) { event.create_course_record! }
      may_not_execute(:update)
    end
  end


  [Event::Course::Role::Affiliated,
   Event::Course::Role::Challenged,
   Event::Course::Role::NotEntitledForBenefit].each do |participant_type|

     context participant_type do
       let(:role_type) { participant_type }

      context 'event' do
        let(:model) { event }
        may_not_execute(:index_participations)
        may_not_execute(:update, :application_market)
      end

      context 'other participation' do
        let(:model) { create_role(Event::Course::Role::Affiliated).participation }
        may_not_execute(:show)
        may_not_execute(:update, :show_details)
      end

      context 'own participation' do
        let(:model) { role.participation }

        may_execute(:show, :show_details)
        may_not_execute(:update)
      end

      context 'role' do
        let(:model) { create_role(Event::Course::Role::Affiliated) }
        may_not_execute(:create, :update, :show, :destroy)
      end

      context 'course_record' do
        let(:model) { event.create_course_record! }
        may_not_execute(:update)
      end
     end
   end
end
