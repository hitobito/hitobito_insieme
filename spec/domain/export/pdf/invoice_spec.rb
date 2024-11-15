#  Copyright (c) 2012-2018, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe Export::Pdf::Invoice do
  let(:recipient) { people(:top_leader) }
  let(:invoice) do
    Invoice.new(
      sequence_number: "1-1",
      payment_slip: :qr,
      total: 1500,
      iban: "CH93 0076 2011 6238 5295 7",
      reference: "RF561A",
      esr_number: "00 00834 96356 70000 00000 00019",
      payee: "Acme Corp\nHallesche Str. 37\n3007 Hinterdupfing",
      recipient: recipient,
      recipient_address: Person::Address.new(recipient).for_invoice,
      issued_at: Date.new(2022, 9, 26),
      due_at: Date.new(2022, 10, 26),
      creator: people(:top_leader),
      vat_number: "CH 1234",
      group: groups(:dachverein)
    )
  end

  before do
    Person::AddressNormalizer.new(recipient).run
  end

  subject do
    pdf = described_class.render(invoice, articles: true)
    PDF::Inspector::Text.analyze(pdf)
  end

  context "without billing address" do
    it "does not render Leistungsbezüger" do
      invoice_text = [
        [347, 685, "Rechnungsnummer:"],
        [453, 685, "1-1"],
        [347, 672, "Rechnungsdatum:"],
        [453, 672, "26.09.2022"],
        [347, 659, "Fällig bis:"],
        [453, 659, "26.10.2022"],
        [347, 646, "Rechnungssteller:"],
        [453, 646, "Top Leader"],
        [347, 632, "MwSt. Nummer:"],
        [453, 632, "CH 1234"],
        [57, 686, "Top Leader"],
        [57, 674, "Teststrasse 23"],
        [57, 662, "3007 Bern"],
        [57, 537, "Rechnungsartikel"],
        [362, 537, "Anzahl"],
        [419, 537, "Preis"],
        [462, 537, "Betrag"],
        [515, 537, "MwSt."],
        [389, 522, "Zwischenbetrag"],
        [506, 522, "0.00 CHF"],
        [389, 504, "Gesamtbetrag"],
        [490, 504, "1'500.00 CHF"]
      ]

      text_with_position.each_with_index do |l, i|
        expect(l).to eq(invoice_text[i])
      end
    end
  end

  context "with differing billing address" do
    before do
      recipient.update(
        billing_general_same_as_main: false,
        billing_general_first_name: "Max",
        billing_general_last_name: "Mustermann",
        billing_general_address: "Musterweg 2",
        billing_general_zip_code: "8000",
        billing_general_town: "Hitobitingen"
      )
    end

    it "renders Leistungsbezüger" do
      invoice_text = [
        [347, 685, "Rechnungsnummer:"],
        [453, 685, "1-1"],
        [347, 672, "Rechnungsdatum:"],
        [453, 672, "26.09.2022"],
        [347, 659, "Fällig bis:"],
        [453, 659, "26.10.2022"],
        [347, 646, "Rechnungssteller:"],
        [453, 646, "Top Leader"],
        [347, 632, "MwSt. Nummer:"],
        [453, 632, "CH 1234"],
        [347, 619, "Leistungsbezüger:"],
        [453, 619, "Top Leader"],
        [57, 686, "Max Mustermann"],
        [57, 674, "Musterweg 2"],
        [57, 662, "8000 Hitobitingen"],
        [57, 537, "Rechnungsartikel"],
        [362, 537, "Anzahl"],
        [419, 537, "Preis"],
        [462, 537, "Betrag"],
        [515, 537, "MwSt."],
        [389, 522, "Zwischenbetrag"],
        [506, 522, "0.00 CHF"],
        [389, 504, "Gesamtbetrag"],
        [490, 504, "1'500.00 CHF"]
      ]

      text_with_position.each_with_index do |l, i|
        expect(l).to eq(invoice_text[i])
      end
    end
  end

  private

  def text_with_position
    subject.positions.each_with_index.collect do |p, i|
      p.collect(&:round) + [subject.show_text[i]]
    end
  end
end
