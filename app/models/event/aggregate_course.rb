#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.
# == Schema Information
#
# Table name: events
#
#  id                          :integer          not null, primary key
#  type                        :string(255)
#  name                        :string(255)      not null
#  number                      :string(255)
#  motto                       :string(255)
#  cost                        :string(255)
#  maximum_participants        :integer
#  contact_id                  :integer
#  description                 :text
#  location                    :text
#  application_opening_at      :date
#  application_closing_at      :date
#  application_conditions      :text
#  kind_id                     :integer
#  state                       :string(60)
#  priorization                :boolean          default(FALSE), not null
#  requires_approval           :boolean          default(FALSE), not null
#  created_at                  :datetime
#  updated_at                  :datetime
#  participant_count           :integer          default(0)
#  application_contact_id      :integer
#  external_applications       :boolean          default(FALSE)
#  applicant_count             :integer          default(0)
#  leistungskategorie          :string(255)
#  teamer_count                :integer          default(0)
#  signature                   :boolean
#  signature_confirmation      :boolean
#  signature_confirmation_text :string
#  creator_id                  :integer
#  updater_id                  :integer
#

class Event::AggregateCourse < Event

  attr_writer :year

  # All attributes actually used (and mass-assignable) by the respective STI type.
  self.used_attributes = [:name, :description, :year]

  # No participations possible
  self.role_types = []

  include Event::Reportable

  validates :year, numericality: { only_integer: true }

  before_validation :update_dates

  def year
    @year || dates.present? && dates.first.start_at.present? && dates.first.start_at.year || nil
  end

  private

  def update_dates
    if @year
      dates.destroy_all
      dates.build(event: self,
                  start_at: Time.zone.local(@year.to_i, 1, 1),
                  finish_at: Time.zone.local(@year.to_i, 12, 31))

      course_record&.set_defaults
    end
  end

end
