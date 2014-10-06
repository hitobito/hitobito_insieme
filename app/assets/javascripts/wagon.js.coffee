#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

$ ->
  $('#person_manual_number').on('change', (event) ->
    $('#person_number').prop('disabled', !this.checked) )

  $('[data-hide]').on('change', (event) ->
    selector = $(this).data('hide')
    if this.checked
      $("##{selector}").slideUp()
    else
      $("##{selector}").slideDown()
  )
