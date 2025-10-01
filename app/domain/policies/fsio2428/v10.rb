module Policies
  module Fsio2428
    class V10
      def self.label
        "BSV2428/V10"
      end

      def include_grundlagen_hours_for?(fachkonzept)
        true
      end
    end
  end
end
