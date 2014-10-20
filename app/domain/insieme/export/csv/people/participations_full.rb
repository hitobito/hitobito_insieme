# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Export::Csv::People
  module ParticipationsFull
    extend ActiveSupport::Concern

    included do
      alias_method_chain :build_attribute_labels, :internal
    end

    def build_attribute_labels_with_internal
      labels = build_attribute_labels_without_internal
      labels[:internal_invoice_text] = human(:internal_invoice_text)
      labels[:internal_invoice_amount] = human(:internal_invoice_amount)
      labels
    end

    private

    def human(attr)
      ::Event::Participation.human_attribute_name(attr)
    end

  end
end
