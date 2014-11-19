# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::Role do
  [Event, Event::Course].each do |event_type|
    event_type.role_types.each do |part|
      context part do
        it 'must have valid permissions' do
          Event::Role::Permissions.should include(*part.permissions)
        end
      end
    end
  end
end