# encoding: utf-8

#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: events
#
#  id                     :integer          not null, primary key
#  type                   :string(255)
#  name                   :string(255)      not null
#  number                 :string(255)
#  motto                  :string(255)
#  cost                   :string(255)
#  maximum_participants   :integer
#  contact_id             :integer
#  description            :text
#  location               :text
#  application_opening_at :date
#  application_closing_at :date
#  application_conditions :text
#  kind_id                :integer
#  state                  :string(60)
#  priorization           :boolean          default(FALSE), not null
#  requires_approval      :boolean          default(FALSE), not null
#  created_at             :datetime
#  updated_at             :datetime
#  participant_count      :integer          default(0)
#  application_contact_id :integer
#  external_applications  :boolean          default(FALSE)
#  applicant_count        :integer          default(0)
#  teamer_count           :integer          default(0)
#  leistungskategorie     :string(255)
#

class Event::AggregateCourse < Event

  # All attributes actually used (and mass-assignable) by the respective STI type.
  self.used_attributes = [:name, :description]

  # No participations possible
  self.role_types = []

  include Event::Reportable

end
