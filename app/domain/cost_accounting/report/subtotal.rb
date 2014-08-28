module CostAccounting
  module Report
    class Subtotal < Base

      class_attribute :summed_reports, :summed_fields

      self.kind = :subtotal

      class << self
        def define_summed_field_methods
          summed_fields.each do |field|
            define_method(field) do
              @summed_fields ||= {}
              @summed_fields[field] ||=
                summed_reports.collect do |report|
                  table.value_of(report, field).to_d
                end.sum
            end
          end
        end
      end


    end
  end
end