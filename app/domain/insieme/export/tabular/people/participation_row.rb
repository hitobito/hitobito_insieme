# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Export::Tabular::People
  module ParticipationRow

    extend ActiveSupport::Concern

    included do
      delegate :multiple_disability, :wheel_chair,
               :invoice_text, :invoice_amount,
               to: :participation
    end

    def disability
      participation.disability_label
    end

  end
end
