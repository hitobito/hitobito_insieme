module CostAccounting
  module Report
    class TimeDistributed < Base

      TIME_FIELDS = %w(verwaltung
                       beratung
                       treffpunkte
                       blockkurse
                       tageskurse
                       jahreskurse
                       lufeb
                       mittelbeschaffung)

      self.used_fields += %w(verwaltung)

      set_editable_fields  %w(aufwand_ertrag_fibu
                              abgrenzung_fibu
                              abgrenzung_dachorganisation)

      delegate :time_record, to: :table

      TIME_FIELDS.each do |f|
        define_method(f) do
          @time_fields ||= {}
          if time_record.total > 0
            @time_fields[f] ||= aufwand_ertrag_ko_re * time_record.send(f).to_d / time_record.total
          end
        end
      end

    end
  end
end

