# frozen_string_literal: true

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module PeopleInsiemeHelper

  def format_person_canton(person)
    person.canton_label
  end

  def format_person_language(person)
    person.language_label
  end

  def format_person_correspondence_language(person)
    person.correspondence_language_label
  end

  def toggled_address_fields(prefix, person = entry)
    display = person.send(:"#{prefix}_same_as_main?") ? 'display: none;' : ''
    content_tag(:div, id: "person_#{prefix}", style: display) do
      yield
    end
  end

  def format_person_dossier(person)
    if person.dossier?
      auto_link(person.dossier, class: 'ellipsis')
    end
  end

  def format_reference_person_number(person)
    render(template: 'people/_reference_person_number',
           locals: { entry: person })
  end

end
