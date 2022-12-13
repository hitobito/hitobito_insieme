# encoding: utf-8

#  Copyright (c) 2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

module Insieme::Export::Pdf::Invoice::InvoiceInformation

  private

  def information_hash
    leistungsbezueger = invoice.recipient.try(:full_name)
    recipient_full_name = invoice.recipient.try(:billing_general_full_name)
    if leistungsbezueger == recipient_full_name
      super
    else
      super.merge(leistungsbezueger: leistungsbezueger)
    end
  end

end
