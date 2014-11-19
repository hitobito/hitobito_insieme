# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Export::Csv::People
  module ParticipationsFull
    extend ActiveSupport::Concern

    included do
      alias_method_chain :build_attribute_labels, :insieme
    end

    def build_attribute_labels_with_insieme
      labels = build_attribute_labels_without_insieme
      labels[:disability] = human(:disability)
      labels[:multiple_disability] = human(:multiple_disability)
      labels[:wheel_chair] = human(:wheel_chair)
      labels[:invoice_text] = human(:invoice_text)
      labels[:invoice_amount] = human(:invoice_amount)
      labels
    end

    private

    def human(attr)
      ::Event::Participation.human_attribute_name(attr)
    end

  end
end
