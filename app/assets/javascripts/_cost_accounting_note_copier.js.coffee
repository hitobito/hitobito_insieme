app = window.App ||= {}

class app.CostAccountingNoteCopier
  constructor: ->

  copy: ->
    target = $('#cost_accounting_record_aufteilung_kontengruppen')[0]
    source = $('#vorheriger-kommentar')[0]

    target.value = source.innerHTML.trim()

  bind: ->
    self = this
    container = '#cost_accounting_note_copy'

    $(document).on 'click', "#{container} a", (e) ->
      e.preventDefault()
      self.copy()

    $(container).removeClass('hidden')

