# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Export::Csv::People
  class ParticipationsComplete < ParticipationsFull

    self.row_class = Export::Csv::People::ParticipationRowComplete

    def build_attribute_labels
      super.merge(custom_labels)
    end

    private

    def custom_labels
      { internal_invoice_text: ::Event::Participation.human_attribute_name(:internal_invoice_text),
        internal_invoice_amount: ::Event::Participation.human_attribute_name(:internal_invoice_amount)
      }
    end
  end
end
