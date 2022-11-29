# frozen_string_literal: true

#  Copyright (c) 2012-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe ContactableInsiemeHelper, type: :helper do
  describe '#contact_method_label_select' do
    let(:additional_email) { people(:top_leader).additional_emails.build(email: 'other@example.com') }
    let(:form) { StandardFormBuilder.new(:additional_email, additional_email, self, {}) }

    standard_options = AdditionalEmail.predefined_labels

    def available_options(html_string)
      Capybara.string(html_string).all(:option).map(&:value)
    end

    it 'has the expected options' do
      result = helper.contact_method_label_select(form)
      expect(result).to have_selector("select[name='additional_email[translated_label]']")

      expect(available_options(result)).to match_array standard_options
    end

    it 'the current value is selected' do
      additional_email.label = standard_options.third
      result = helper.contact_method_label_select(form)

      expect(result).to have_selector("option[value='#{standard_options.third}'][selected='selected']")
    end

    it 'includes current value as option' do
      additional_email.label = 'nonstandard_value'
      result = helper.contact_method_label_select(form)

      expect(available_options(result)).to match_array [*standard_options, 'nonstandard_value']
    end

    it 'the nonstandard value is selected' do
      additional_email.label = 'nonstandard_value'
      result = helper.contact_method_label_select(form)

      expect(result).to have_selector("option[value='nonstandard_value'][selected='selected']")
    end
  end
end
