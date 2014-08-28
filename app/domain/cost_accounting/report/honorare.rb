module CostAccounting
  module Report
    class Honorare < Base

      self.used_fields += %w(verwaltung)

      set_editable_fields  %w(aufwand_ertrag_fibu
                              aufteilung_kontengruppen
                              abgrenzung_fibu
                              abgrenzung_dachorganisation

                              verwaltung
                              beratung
                              treffpunkte
                              blockkurse
                              tageskurse
                              jahreskurse
                              lufeb
                              mittelbeschaffung)

      self.kontengruppe = '509/4300'

    end
  end
end