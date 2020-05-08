# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Person::AddressNormalizer do
  let(:attrs) { { first_name: 'Puzzle',
                  last_name: 'ITC',
                  address: 'Eigerplatz 4',
                  zip_code: '3007',
                  town: 'Bern',
                  country: 'CH' } }

  let(:person) { Person.new(attrs) }
  before { Person::AddressNormalizer.new(person).run }

  context 'blank values' do
    %w(correspondence_general correspondence_course billing_general billing_course).each do |type|
      it "updates #{type} values to main field values" do
        expect(value(type, :first_name)).to eq 'Puzzle'
        expect(value(type, :last_name)).to eq 'ITC'
        expect(value(type, :address)).to eq 'Eigerplatz 4'
        expect(value(type, :zip_code)).to eq 3007
        expect(value(type, :town)).to eq 'Bern'
        expect(value(type, :country)).to eq 'CH'
        expect(value(type, :company)).to be_falsey
        expect(value(type, :same_as_main)).to be_truthy
      end
    end
  end

  context 'differing values' do
    let(:person) { Person.new(attrs.merge(billing_course_same_as_main: false,
                                          billing_course_first_name: 'Insieme')) }

    it 'keeps differing values' do
      expect(value(:billing_course, :first_name)).to eq 'Insieme'

      %w(address zip_code town country company).each do |field|
        expect(value(:billing_course, field)).not_to be_present
      end
    end

    it 'updates same_as_main to false' do
      expect(value(:billing_course, :same_as_main)).to be_falsey
    end
  end


  context 'identical values' do
    let(:person) { Person.new(attrs.merge(billing_course_first_name: 'Puzzle',
                                          billing_course_last_name: 'ITC',
                                          billing_course_address: 'Eigerplatz 4',
                                          billing_course_zip_code: 3007,
                                          billing_course_town: 'Bern',
                                          billing_course_country: 'CH',
                                          billing_course_same_as_main: false)) }
    it 'keeps values identical' do
      expect(value(:billing_course, :first_name)).to eq 'Puzzle'
      expect(value(:billing_course, :last_name)).to eq 'ITC'
      expect(value(:billing_course, :address)).to eq 'Eigerplatz 4'
      expect(value(:billing_course, :zip_code)).to eq 3007
      expect(value(:billing_course, :town)).to eq 'Bern'
      expect(value(:billing_course, :country)).to eq 'CH'
      expect(value(:billing_course, :company)).to be_falsey
    end

    it 'updates same_as_main to true' do
      expect(value(:billing_course, :same_as_main)).to be_truthy
    end
  end

  context 'persisted values' do
    let(:person) { Person.create!(attrs) }

    it 'does update others when updating main' do
      person.update_attribute(:town, 'Thun')
      expect(person.reload.billing_general_town).to eq 'Thun'
    end

    it 'does not persist changed value if same_as_main is set' do
      person.update_attribute(:billing_general_first_name, 'Insieme')
      expect(person.reload.billing_general_first_name).to eq 'Puzzle'
    end

    it 'does persist changed value if same_as_main is set to false' do
      person.update(billing_general_first_name: 'Insieme',
                               billing_general_same_as_main: false)
      expect(person.reload.billing_general_first_name).to eq 'Insieme'
    end
  end

  def value(type, field)
    person.send([type,field].join('_'))
  end
end
