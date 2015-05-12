# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.
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
#

require 'spec_helper'

describe Event::AggregateCourse do

  context '#year' do
    let(:event) do
      Event::AggregateCourse.new(groups: [groups(:dachverein)],
                                 leistungskategorie: 'bk',
                                 name: 'Foo')
    end

    it 'should cause a validation error if not set' do
      expect(event.valid?).to be_falsey
      expect(event.errors[:year]).to be_present
    end

    it 'should cause a validation error if string' do
      event.year = 'asdf'
      expect(event.valid?).to be_falsey
      expect(event.errors[:year]).to be_present
    end

    it 'should cause a validation error if float' do
      event.year = 1.5
      expect(event.valid?).to be_falsey
      expect(event.errors[:year]).to be_present
    end

    it 'should add date according to given year' do
      event.year = 2000
      expect(event.valid?).to be_truthy

      start_at = event.dates.first.start_at
      finish_at = event.dates.first.finish_at
      expect(start_at.year).to eq(2000)
      expect(start_at.month).to eq(1)
      expect(start_at.day).to eq(1)
      expect(finish_at.year).to eq(2000)
      expect(finish_at.month).to eq(12)
      expect(finish_at.day).to eq(31)
    end

  end
end
