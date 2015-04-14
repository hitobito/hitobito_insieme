# encoding: utf-8

#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class Event::AggregateCourse < Event

  # All attributes actually used (and mass-assignable) by the respective STI type.
  self.used_attributes = [:name, :description]

  # No participations possible
  self.role_types = []

  include Event::Reportable

end