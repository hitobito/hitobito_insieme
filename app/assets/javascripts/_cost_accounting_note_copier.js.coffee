app = window.App ||= {}

class app.CostAccountingNoteCopier
  constructor: ->
    @target = $('#cost_accounting_record_aufteilung_kontengruppen')[0]
    @source = $('#vorheriger-kommentar')[0]
    @container = '#cost_accounting_note_copy'

  copy: ->
    @target.value = @source.innerHTML.trim()

  bind: ->
    self = this

    $(document).on 'click', "#{@container} a", (e) ->
      e.preventDefault()
      self.copy()

    $(@container).removeClass('hidden')

