# encoding: utf-8

#  Copyright (c) 2014, Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Export::Pdf::Labels do


  let(:person) { people(:top_leader) }

  let(:labels) { Export::Pdf::Labels.new(Fabricate(:label_format), address_type) }

  subject { labels.send(:address, person, to_name(person)) }

  def to_name(contactable)
    Export::Tabular::People::HouseholdRow.new(contactable).name
  end

  before do
    person.update!(
      address: 'My Street',
      town: 'Bern',
      correspondence_course_same_as_main: false,
      correspondence_course_first_name: 'Course',
      correspondence_course_last_name: 'Leader',
      correspondence_course_company_name: 'Chiefs Inc',
      correspondence_course_address: 'Course Street',
      correspondence_course_zip_code: '3030',
      correspondence_course_town: 'Wabern',
      correspondence_course_country: 'Schweiz'
    )
  end

  context 'for main address' do
    let(:address_type) { 'main' }

    it 'renders correct address' do
      is_expected.to eq "Top Leader\nMy Street\n Bern\n"
    end
  end

  context 'for correspondence course address' do
    let(:address_type) { 'correspondence_course' }

    it 'renders correct address' do
      is_expected.to eq "Chiefs Inc\nCourse Leader\nCourse Street\n3030 Wabern\n"
    end
  end
end
