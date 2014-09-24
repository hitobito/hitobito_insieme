# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Insieme::AbilityDsl::Constraints::Event do

  let(:event)   { events(:top_course) }
  let(:ability) { Ability.new(create_role.person.reload) }

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


  context Event::Course::Role::LeaderBasic do
    let(:role_type) { Event::Course::Role::LeaderBasic }

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


  context Event::Course::Role::Caregiver do
    let(:role_type) { Event::Course::Role::Caregiver }

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
end

