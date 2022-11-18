# frozen_string_literal: true

#  Copyright (c) 2012-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe PeopleInsiemeHelper, type: :helper do
  let(:person) { people(:top_leader) }

  describe '#address_label_select' do
    let(:form) { StandardFormBuilder.new(:person, person, self, {}) }

    expected_options = Settings.addresses.predefined_labels + ['']

    %w(correspondence_general correspondence_course billing_general billing_course).each do |address_type|
      context "with prefix=#{address_type}" do
        def available_options(html_string)
          Capybara.string(html_string).all(:option).map(&:value)
        end

        it 'has the expected options' do
          result = helper.address_label_select(form, address_type)
          expect(result).to have_selector("select[name='person[#{address_type}_label]']")

          expect(available_options(result)).to match_array expected_options
        end

        it 'the current value is selected' do
          person.send("#{address_type}_label=", expected_options.third)
          result = helper.address_label_select(form, address_type)

          expect(result).to have_selector("option[value='#{expected_options.third}'][selected='selected']")
        end

        it 'includes current value as option' do
          person.send("#{address_type}_label=", 'nonstandard_value')
          result = helper.address_label_select(form, address_type)

          expect(available_options(result)).to match_array [*expected_options, 'nonstandard_value']
        end

        it 'the nonstandard value is selected' do
          person.send("#{address_type}_label=", 'nonstandard_value')
          result = helper.address_label_select(form, address_type)

          expect(result).to have_selector("option[value='nonstandard_value'][selected='selected']")
        end
      end
    end
  end
end
