# encoding: utf-8

#  Copyright (c) 2012-2018, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'


describe Export::Pdf::Invoice do
  let(:recipient) { people(:top_leader) }
  let(:invoice) do
    Invoice.new(
      sequence_number: '1-1',
      payment_slip: :qr,
      total: 1500,
      iban: 'CH93 0076 2011 6238 5295 7',
      reference: 'RF561A',
      esr_number: '00 00834 96356 70000 00000 00019',
      payee: "Acme Corp\nHallesche Str. 37\n3007 Hinterdupfing",
      recipient: recipient,
      recipient_address: Person::Address.new(recipient).for_invoice,
      issued_at: Date.new(2022, 9, 26),
      due_at: Date.new(2022, 10, 26),
      creator: people(:top_leader),
      vat_number: 'CH 1234',
      group: groups(:dachverein),
    )
  end

  before do
    Person::AddressNormalizer.new(recipient).run
  end

  subject do
    pdf = described_class.render(invoice, articles: true)
    PDF::Inspector::Text.analyze(pdf)
  end

  context 'without billing address' do
    it 'does not render Leistungsbezüger' do
      expect(text_with_position).to eq [
        [347, 687, "Rechnungsnummer:"],
        [457, 687, "1-1"],
        [347, 674, "Rechnungsdatum:"],
        [457, 674, "26.09.2022"],
        [347, 662, "Fällig bis:"],
        [457, 662, "26.10.2022"],
        [347, 649, "Rechnungssteller:"],
        [457, 649, "Top Leader"],
        [347, 637, "MwSt. Nummer:"],
        [457, 637, "CH 1234"],
        [57, 688, "Top Leader"],
        [57, 676, "Teststrasse 23"],
        [57, 665, "3007 Bern"],
        [57, 539, "Rechnungsartikel"],
        [363, 539, "Anzahl"],
        [419, 539, "Preis"],
        [464, 539, "Betrag"],
        [515, 539, "MwSt."],
        [420, 526, "Zwischenbetrag"],
        [505, 526, "0.00 CHF"],
        [420, 513, "MwSt."],
        [505, 513, "0.00 CHF"],
        [420, 496, "Gesamtbetrag"],
        [490, 496, "1'500.00 CHF"]
      ]
    end
  end

  context 'with differing billing address' do
    before do
      recipient.update(
        billing_general_same_as_main: false,
        billing_general_first_name:  'Max',
        billing_general_last_name:  'Mustermann',
        billing_general_address:  'Musterweg 2',
        billing_general_zip_code:  '8000',
        billing_general_town:  'Hitobitingen',
        )
    end

    it 'renders Leistungsbezüger' do
      expect(text_with_position).to eq [
        [347, 687, "Rechnungsnummer:"],
        [458, 687, "1-1"],
        [347, 674, "Rechnungsdatum:"],
        [458, 674, "26.09.2022"],
        [347, 662, "Fällig bis:"],
        [458, 662, "26.10.2022"],
        [347, 649, "Rechnungssteller:"],
        [458, 649, "Top Leader"],
        [347, 637, "MwSt. Nummer:"],
        [458, 637, "CH 1234"],
        [347, 624, "Leistungsbezüger:"],
        [458, 624, "Top Leader"],
        [57, 688, "Max Mustermann"],
        [57, 676, "Musterweg 2"],
        [57, 665, "8000 Hitobitingen"],
        [57, 539, "Rechnungsartikel"],
        [363, 539, "Anzahl"],
        [419, 539, "Preis"],
        [464, 539, "Betrag"],
        [515, 539, "MwSt."],
        [420, 526, "Zwischenbetrag"],
        [505, 526, "0.00 CHF"],
        [420, 513, "MwSt."],
        [505, 513, "0.00 CHF"],
        [420, 496, "Gesamtbetrag"],
        [490, 496, "1'500.00 CHF"]
      ]
    end
  end

  private

  def text_with_position
    subject.positions.each_with_index.collect do |p, i|
      p.collect(&:round) + [subject.show_text[i]]
    end
  end
end
