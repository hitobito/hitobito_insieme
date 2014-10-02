# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Person::AddressUpdater do
  let(:attrs) { { first_name: 'Puzzle',
                  last_name: 'ITC',
                  address: 'Eigerplatz 4',
                  zip_code: 3007,
                  town: 'Bern',
                  country: 'Schweiz' } }

  let(:person) { Person.new(attrs) }
  before { Person::AddressUpdater.new(person).run }

  context 'blank values' do
    %w(correspondence_general correspondence_course billing_general billing_course).each do |type|
      it "updates #{type} values to main field values" do
        value(type, :full_name).should eq 'Puzzle ITC'
        value(type, :address).should eq 'Eigerplatz 4'
        value(type, :zip_code).should eq 3007
        value(type, :town).should eq 'Bern'
        value(type, :country).should eq 'Schweiz'
        value(type, :company).should be_false
        value(type, :same_as_main).should be_true
      end
    end
  end

  context 'differing values' do
    let(:person) { Person.new(attrs.merge(billing_course_same_as_main: false,
                                          billing_course_full_name: 'Insieme')) }

    it 'keeps differing values' do
      value(:billing_course, :full_name).should eq 'Insieme'

      %w(address zip_code town country company).each do |field|
        value(:billing_course, field).should_not be_present
      end
    end

    it 'updates same_as_main to false' do
      value(:billing_course, :same_as_main).should be_false
    end
  end


  context 'identical values' do
    let(:billing_course_attrs) { attrs.reject { |k,v| k =~ /name/ }.map { |k, v| ["billing_course_#{k}", v] }.to_h }

    let(:person) { Person.new(attrs.merge(billing_course_attrs.merge(billing_course_same_as_main: false,
                                                                     billing_course_full_name: 'Puzzle ITC'))) }
    it 'keeps values identical' do
      value(:billing_course, :full_name).should eq 'Puzzle ITC'
      value(:billing_course, :address).should eq 'Eigerplatz 4'
      value(:billing_course, :zip_code).should eq 3007
      value(:billing_course, :town).should eq 'Bern'
      value(:billing_course, :country).should eq 'Schweiz'
      value(:billing_course, :company).should be_false
    end

    it 'updates same_as_main to true' do
      value(:billing_course, :same_as_main).should be_true
    end
  end

  context 'assigning values' do
    let(:person) { Person.create!(attrs) }

    it 'does not mark person as changed when resetting same value' do
      person.billing_general_full_name = 'Puzzle ITC'
      Person::AddressUpdater.new(person).run
      person.should_not be_changed
    end
  end

  def value(type, field)
    person.send([type,field].join('_'))
  end
end
