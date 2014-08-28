module CostAccountingHelper
  def cost_accounting_input_fields(f, *fields)
    safe_join(fields) do |field|
      if report.editable_fields.include?(field.to_s)
        f.labeled_input_field(field)
      end
    end
  end

  def cost_account_field_class(field)
    'subtotal' if %w(aufwand_ertrag_ko_re total).include?(field)
  end
end