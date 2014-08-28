module CostAccounting
  module Report
    class Persisted < Base

      class_attribute :persisted_fields
      self.persisted_fields = []

      self.editable = true

      class << self
        def set_persisted_fields(fields)
          self.persisted_fields = fields
          delegate *fields, to: :record
        end
      end

      def record
        @record ||= table.cost_record(self.class.key)
      end

    end
  end
end