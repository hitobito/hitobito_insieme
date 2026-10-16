#  Copyright (c) 2012-2018, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe Export::Pdf::Invoice do
  let(:recipient) { people(:top_leader) }
  let(:invoice) do
    Fabricate.build(:invoice,
      Person::Address.new(recipient).invoice_recipient_address_attributes.merge({
        sequence_number: "1-1",
        payment_slip: :qr,
        total: 1500,
        iban: "CH93 0076 2011 6238 5295 7",
        reference: "RF561A",
        esr_number: "00 00834 96356 70000 00000 00019",
        recipient: recipient,
        issued_at: Date.new(2022, 9, 26),
        due_at: Date.new(2022, 10, 26),
        creator: people(:top_leader),
        vat_number: "CH 1234",
        group: groups(:dachverein)
      }))
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
        [57, 554, invoice.title],
        [57, 521, "Rechnungsartikel"],
        [412, 521, "Anzahl"],
        [469, 521, "Preis"],
        [512, 521, "Betrag"],
        [389, 506, "Zwischenbetrag"],
        [506, 506, "0.00 CHF"],
        [389, 488, "Gesamtbetrag"],
        [490, 488, "1'500.00 CHF"]
      ]
      expect(text_with_position).to eq invoice_text
    end
  end

  context "with differing billing address" do
    before do
      Fabricate(:additional_address,
        contactable: recipient,
        category: contact_account_categories(:additional_address_person_invoices),
        uses_contactable_name: false,
        first_name: "Max",
        last_name: "Mustermann",
        street: "Musterweg",
        housenumber: "2",
        zip_code: "8000",
        town: "Hitobitingen",
        country: "CH")
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
        [57, 554, invoice.title],
        [57, 521, "Rechnungsartikel"],
        [412, 521, "Anzahl"],
        [469, 521, "Preis"],
        [512, 521, "Betrag"],
        [389, 506, "Zwischenbetrag"],
        [506, 506, "0.00 CHF"],
        [389, 488, "Gesamtbetrag"],
        [490, 488, "1'500.00 CHF"]
      ]

      expect(text_with_position).to eq invoice_text
    end
  end

  private

  def text_with_position
    subject.positions.each_with_index.collect do |p, i|
      p.collect(&:round) + [subject.show_text[i]]
    end
  end
end
