# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.
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

require 'spec_helper'

describe Event::AggregateCourse do

  let(:event) do
    Event::AggregateCourse.new(groups: [groups(:dachverein)],
                               leistungskategorie: 'bk',
                               fachkonzept: 'sport_jugend',
                               name: 'Foo')
  end

  context '#year' do

    it 'causes a validation error if not set' do
      expect(event.valid?).to be_falsey
      expect(event.errors[:year]).to be_present
    end

    it 'causes a validation error if empty string' do
      event.year = ''
      expect(event.valid?).to be_falsey
      expect(event.errors[:year]).to be_present
    end

    it 'causes a validation error if string' do
      event.year = 'asdf'
      expect(event.valid?).to be_falsey
      expect(event.errors[:year]).to be_present
    end

    it 'causes a validation error if float' do
      event.year = 1.5
      expect(event.valid?).to be_falsey
      expect(event.errors[:year]).to be_present
    end

    it 'adds date according to given year' do
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

    it 'represents year of first date' do
      event.year = 2000
      expect(event.year).to eq(2000)
      event.save!
      expect(Event::AggregateCourse.find(event.id).year).to eq(2000)
    end

    it 'can be updated' do
      event.year = 2000
      event.save!
      event_id = event.id

      event.year = 2001
      expect(event.year).to eq(2001)
      event.save!

      event = Event::AggregateCourse.find(event_id)
      expect(event.dates.length).to eq(1)
      expect(event.year).to eq(2001)
    end

    it 'causes a validation error on invalid update' do
      event.year = 2000
      event.save!
      event_id = event.id

      event = Event::AggregateCourse.find(event_id)
      event.year = ''
      expect(event.valid?).to be_falsey
      expect(event.errors[:year]).to be_present
    end
  end

  context 'frozen reporting' do
    before { event.build_course_record }
    before { GlobalValue.first.update!(reporting_frozen_until_year: 2015) }
    after  { GlobalValue.clear_cache }

    it 'cannot create new record' do
      event.year = 2014
      expect(event).to have(1).error_on(:base)
      expect(event.errors.full_messages.uniq.size).to eq(1) # just one message for the same issue
    end

    it 'cannot change year into frozen period' do
      event.year = 2016
      event.save!
      event.year = 2015
      expect(event).to have(1).error_on(:base)
    end

    it 'cannot destroy frozen period' do
      GlobalValue.first.update!(reporting_frozen_until_year: 2015)
      event.year = 2016
      event.save!
      GlobalValue.first.update!(reporting_frozen_until_year: 2016)
      expect { event.destroy }.not_to change { Event.count }
    end

  end

end
