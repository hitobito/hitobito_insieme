# frozen_string_literal: true

#  Copyright (c) 2012-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module ContactableInsiemeHelper
  def additional_email_label_select(additional_email_form)
    additional_email = additional_email_form.object
    current_label = additional_email.label
    options = (additional_email.class.predefined_labels | [current_label].compact).map do |value|
      translated = additional_email.class.translate_label(value)
      OpenStruct.new(value: value, translated: translated)
    end
    additional_email_form.collection_select(:translated_label, options, :value, :translated, {}, class: 'span2')
  end
end
