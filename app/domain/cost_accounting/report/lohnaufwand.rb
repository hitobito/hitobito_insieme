module CostAccounting
  module Report
    class Lohnaufwand < TimeDistributed

      self.used_fields = %w(kontengruppe
                            aufwand_ertrag_fibu
                            abgrenzung_fibu
                            abgrenzung_dachorganisation
                            kosten_ertrag_ko_re

                            verwaltung
                            beratung
                            treffpunkte
                            blockkurse
                            tageskurse
                            jahreskurse
                            lufeb
                            mittelbeschaffung
                            total
                            kontrolle)

      set_persisted_fields %w(aufwand_ertrag_fibu
                              abgrenzung_fibu
                              abgrenzung_dachorganisation)

      self.kontengruppe = '500'

    end
  end
end