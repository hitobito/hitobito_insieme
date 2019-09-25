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
      @duration_days ||= CourseDays.new(event.dates).sum
    end

    def duration_hours
      @duration_hours ||=
        event.dates.inject(0) do |sum, date|
          d = date.duration
          sum + (d.finish_at ? ((d.finish_at - d.start_at) / 3600).round : 0)
        end
    end

    def challenged_count
      role_count(Event::Course::Role::Challenged)
    end

    def challenged_multiple_count
      @challenged_multiple_count ||=
        event.participations.joins(:roles)
             .where(active: true, multiple_disability: true)
             .where(event_roles: { type: Event::Course::Role::Challenged.sti_name })
             .distinct
             .count
    end

    def affiliated_count
      role_count(Event::Course::Role::Affiliated)
    end

    def challenged_canton_counts
      @challenged_canton_counts ||= canton_counts(Event::Course::Role::Challenged)
    end

    def affiliated_canton_counts
      @affiliated_canton_counts ||= canton_counts(Event::Course::Role::Affiliated)
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

    def caretaker_count
      role_count(Event::Course::Role::Caretaker)
    end

    def team_count
      leader_count +
      expert_count +
      helper_paid_count +
      helper_unpaid_count +
      caretaker_count
    end

    def participant_count
      challenged_count +
      affiliated_count +
      not_entitled_for_benefit_count
    end

    def invoice_amount_sum
      event.participations.
        map(&:invoice_amount).
        map(&:to_d).
        inject(&:+)
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

    def canton_counts(role)
      counts = event.participations.includes(:roles)
                    .joins(:roles, :person)
                    .where(event_roles: { type: role.sti_name })
                    .group('people.canton').count
      counts['undefined'] = ((counts.delete(nil) || 0) + (counts.delete('') || 0))
      counts
    end
  end
end
