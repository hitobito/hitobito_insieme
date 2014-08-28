module CostAccounting
  module Report
    class TotalPersonalaufwand < Subtotal

      self.used_fields += %w(verwaltung)

      self.summed_reports = %w(lohnaufwand
                               sozialversicherungsaufwand
                               uebriger_personalaufwand
                               honorare)

      self.summed_fields = %w(aufwand_ertrag_fibu
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

      define_summed_field_methods

    end
  end
end