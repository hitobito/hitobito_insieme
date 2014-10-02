#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

$ ->
  $('#person_manual_number').on('change', (event) ->
    $('#person_number').prop('disabled', !this.checked) )

  $(':checkbox[id$=same_as_main]').on('change', (event) ->
    selector = event.target.id.replace('_same_as_main', '')
    $("##{selector}").toggleClass('hidden') )
