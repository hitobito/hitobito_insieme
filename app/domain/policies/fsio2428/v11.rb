module Policies
  module Fsio2428
    class V11
      def self.label
        "BSV2428/V11"
      end

      # Stop adding Grundlagenarbeit to export client_statistics for
      # the leistungskategorien  sk, bk and tk, but keep adding for tp.
      def include_grundlagen_hours_for?(fachkonzept)
        fachkonzept == "treffpunkt"
      end
    end
  end
end
