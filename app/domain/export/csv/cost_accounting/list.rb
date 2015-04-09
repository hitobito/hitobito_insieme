# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.


module Export::Csv::CostAccounting
  class List < Export::Csv::Base

    self.model_class = CostAccounting::Report::Base
    self.row_class = Export::Csv::CostAccounting::Row

    def build_attribute_labels
      {}.tap do |labels|
        labels[:report] = human(:report)
        labels[:kontengruppe] = human(:kontengruppen)

        CostAccounting::Report::Base::FIELDS.each do |field|
          labels[field.to_sym] = human(field)
        end
      end
    end

    private

    def human(field)
      I18n.t("activerecord.attributes.cost_accounting_record.#{field}")
    end

  end
end
