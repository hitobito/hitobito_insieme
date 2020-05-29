#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Export::Tabular::People
  module ParticipationsFull

    def build_attribute_labels
      super.tap do |labels|
        labels[:disability] = human(:disability)
        labels[:multiple_disability] = human(:multiple_disability)
        labels[:wheel_chair] = human(:wheel_chair)
        labels[:invoice_text] = human(:invoice_text)
        labels[:invoice_amount] = human(:invoice_amount)
        labels
      end
    end

    private

    def human(attr)
      ::Event::Participation.human_attribute_name(attr)
    end

  end
end
