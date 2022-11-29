# frozen_string_literal: true

#  Copyright (c) 2012-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module ContactableInsiemeHelper
  def contact_method_label_select(contact_method_form)
    contact_method = contact_method_form.object
    current_label = contact_method.label
    options = (contact_method.class.predefined_labels | [current_label].compact).map do |value|
      translated = contact_method.class.translate_label(value)
      OpenStruct.new(value: value, translated: translated)
    end
    contact_method_form.collection_select(:translated_label, options, :value, :translated, {}, class: 'span2')
  end
end
