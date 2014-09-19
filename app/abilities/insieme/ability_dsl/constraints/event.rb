# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::AbilityDsl::Constraints::Event
  extend ActiveSupport::Concern

  included do
    alias_method_chain :for_event_contacts, :course_specific_roles
    alias_method_chain :for_managed_events, :course_specific_roles
    alias_method_chain :for_leaded_events, :course_specific_roles
  end

  def for_event_contacts_with_course_specific_roles
    if event.is_a?(Event::Course)
      (permission_in_event?(:participation_read) || permission_in_event?(:participation_full))
    else
      for_event_contacts_without_course_specific_roles
    end
  end

  def for_leaded_events_with_course_specific_roles
    if event.is_a?(Event::Course)
      permission_in_event?(:event_full)
    else
      for_managed_events_without_course_specific_roles
    end
  end

  def for_managed_events_with_course_specific_roles
    if event.is_a?(Event::Course)
      permission_in_event?(:event_full)
    else
      for_managed_events_without_course_specific_roles
    end
  end
end
