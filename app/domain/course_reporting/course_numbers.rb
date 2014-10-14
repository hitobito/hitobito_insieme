# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module CourseReporting
  class CourseNumbers

    attr_reader :event

    def initialize(event)
      @event = event
    end

    def duration_days
      @duration_days ||=
        event.dates.inject(0) { |sum, date| sum + date.duration.days }
    end

    def challenged_count
      role_count(Event::Course::Role::Challenged)
    end

    def affiliated_count
      role_count(Event::Course::Role::Affiliated)
    end

    def not_entitled_for_benefit_count
      role_count(Event::Course::Role::NotEntitledForBenefit)
    end

    def leader_count
      role_count(Event::Course::Role::LeaderAdmin) +
      role_count(Event::Course::Role::LeaderReporting) +
      role_count(Event::Course::Role::LeaderBasic)
    end

    def expert_count
      role_count(Event::Course::Role::Expert)
    end

    def helper_paid_count
      role_count(Event::Course::Role::HelperPaid)
    end

    def helper_unpaid_count
      role_count(Event::Course::Role::HelperUnpaid)
    end

    def kitchen_count
      role_count(Event::Course::Role::Kitchen)
    end

    def team_count
      leader_count +
      expert_count +
      helper_paid_count +
      helper_unpaid_count
    end

    def participant_count
      challenged_count +
      affiliated_count +
      not_entitled_for_benefit_count
    end

    private

    def role_count(type)
      @role_count ||= count_participation_roles
      @role_count[type]
    end

    def count_participation_roles
      counts = Hash.new { |h, k| h[k] = 0 }
      event.participations.includes(:roles).find_each do |p|
        count_highest_type(counts, p.roles.collect(&:class))
      end
      counts
    end

    def count_highest_type(counts, types)
      event.role_types.each do |type|
        if types.include?(type)
          counts[type] += 1
          break
        end
      end
    end

  end
end