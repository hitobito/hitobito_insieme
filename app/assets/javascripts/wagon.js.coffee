#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

#= require ./_cost_accounting_calculator.js.coffee

$(document).on('click', '.cancel[href="#"]', (event) ->
  $(this).closest('form').get(0).reset())

$(document).on('turbolinks:load', ->
  $('#person_manual_number').on('change', (event) ->
    $('#person_number').prop('disabled', !this.checked) )

  $('form[data-readonly=true] input, ' +
    'form[data-readonly=true] textarea, ' +
    'form[data-readonly=true] select').attr('readonly', 'readonly')

  $('form[data-readonly=true] input[type=checkbox], ' +
    'form[data-readonly=true] input[type=radio]').attr('disabled', 'disabled')
)
