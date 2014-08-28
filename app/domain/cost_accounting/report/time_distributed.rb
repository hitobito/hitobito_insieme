module CostAccounting
  module Report
    class TimeDistributed < Persisted

      TIME_FIELDS = %w(verwaltung
                       beratung
                       treffpunkte
                       blockkurse
                       tageskurse
                       jahreskurse
                       lufeb
                       mittelbeschaffung)

      delegate :time_record, to: :table

      TIME_FIELDS.each do |f|
        define_method f do
          @time_fields ||= {}
          @time_fields[f] ||= aufwand_ertrag_ko_re * time_record.send(f).to_d / time_record.total if time_record.total > 0
        end
      end

    end
  end
end

