# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Person do

  context 'canton_value' do

    it 'is blank for nil value' do
      Person.new.canton_value.should be_blank
    end

    it 'is blank for blank value' do
      Person.new(canton: '').canton_value.should be_blank
    end

    it 'is locale specific value for valid key' do
      Person.new(canton: 'be').canton_value.should eq 'Bern'
    end
  end

  context 'insieme_full_name' do
    it 'can be custom defined' do
      person = Person.new
      person.first_name = 'John'
      person.last_name = 'Lennon'
      person.insieme_full_name.should be_blank
      person.insieme_full_name = 'George Harrison'
      person.save!
      person.insieme_full_name.should eq 'George Harrison'
    end

    it 'falls back to first_name + last_name if blank' do
      person = Person.new
      person.first_name = 'John'
      person.last_name = 'Lennon'
      person.save!
      person.insieme_full_name.should eq 'John Lennon'
    end

    it 'can be updated and falls back to first_name + last_name when changed to blank' do
      person = Person.new
      person.first_name = 'John'
      person.last_name = 'Lennon'
      person.save!
      person.insieme_full_name.should eq 'John Lennon'

      person.insieme_full_name = 'George Harrison'
      person.save!
      person.insieme_full_name.should eq 'George Harrison'

      person.insieme_full_name = ''
      person.save!
      person.insieme_full_name.should eq 'John Lennon'
    end

    it 'doesn\'t update if defined' do
      person = Person.new
      person.first_name = 'John'
      person.last_name = 'Lennon'
      person.save!
      person.insieme_full_name.should eq 'John Lennon'

      person.first_name = 'Paul'
      person.last_name = 'McCartney'
      person.save!
      person.insieme_full_name.should eq 'John Lennon'

      person.insieme_full_name = 'Ringo Starr'
      person.save!

      person.first_name = 'Brian'
      person.last_name = 'Epstein'
      person.save!
      person.insieme_full_name.should eq 'Ringo Starr'
    end
  end

end
