app = window.Application ||= {}

class app.CostAccountingCalculator
  constructor: () ->

  updateValues: ->
    $('#aufwand_ertrag_ko_re').html(@formatMoney(@aufwandErtragKoRe()))
    $('#control_value').html(@formatMoney(@kontrolle()))

  bind: ->
    self = this
    $(document).on(
      'keyup change',
      '#cost_accounting_record_aufwand_ertrag_fibu,
       #cost_accounting_record_abgrenzung_dachorganisation,
       #cost_accounting_record_abgrenzung_fibu,
       #cost_accounting_record_raeumlichkeiten,
       #cost_accounting_record_verwaltung,
       #cost_accounting_record_beratung,
       #cost_accounting_record_treffpunkte,
       #cost_accounting_record_blockkurse,
       #cost_accounting_record_tageskurse,
       #cost_accounting_record_jahreskurse,
       #cost_accounting_record_lufeb,
       #cost_accounting_record_mittelbeschaffung'
      (e) -> self.updateValues())

  aufwandErtragKoRe: ->
    @floatVal('#cost_accounting_record_aufwand_ertrag_fibu') -
      @floatVal('#cost_accounting_record_abgrenzung_dachorganisation') -
      @abgrenzungFibu()

  total: ->
    @floatVal('#cost_accounting_record_raeumlichkeiten') +
      @floatVal('#cost_accounting_record_verwaltung') +
      @floatVal('#cost_accounting_record_beratung') +
      @floatVal('#cost_accounting_record_treffpunkte') +
      @floatVal('#cost_accounting_record_blockkurse') +
      @floatVal('#cost_accounting_record_tageskurse') +
      @floatVal('#cost_accounting_record_jahreskurse') +
      @floatVal('#cost_accounting_record_lufeb') +
      @floatVal('#cost_accounting_record_mittelbeschaffung')

  kontrolle: ->
    @total() - @aufwandErtragKoRe()

  abgrenzungFibu: ->
    if @abgrenzungFactor()
      @floatVal('#cost_accounting_record_aufwand_ertrag_fibu') * @abgrenzungFactor()
    else
      @floatVal('#cost_accounting_record_abgrenzung_fibu')

  abgrenzungFactor: ->
    factor = $('#aufwand_ertrag_ko_re').data('abgrenzung-factor')
    if factor then parseFloat(factor) else null

  floatVal: (field) ->
    float = parseFloat($(field).val() || 0)
    if isNaN(float) then 0 else float

  formatMoney: (value) ->
    value.toFixed(2) + ' CHF'

new app.CostAccountingCalculator().bind()
