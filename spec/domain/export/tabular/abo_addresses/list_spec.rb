#  Copyright (c) 2014-2024, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Export::Tabular::AboAddresses::List do
  let(:people_list) { AboAddresses::Query.new(true, "de").people }

  let(:list) { described_class.new(people_list) }

  context "#attribute_labels" do
    subject { list.attribute_labels }

    it "contains hard-coded attribute labels" do
      expect(subject[:number]).to eq "Kd.Nr."
      expect(subject[:name]).to eq "Vorname und Name"
      expect(subject[:address_1]).to eq "Adresse 1"
    end
  end

  context "#data_rows" do
    subject { list.data_rows.to_a }

    it "has one item per person" do
      expect(subject.size).to eq 1
    end

    it "contains the correct values" do
      people(:regio_aktiv).update!(first_name: "Hans",
        last_name: "Muster",
        company_name: "Firma",
        street: "Eigerplatz",
        housenumber: "4",
        postbox: "Postfach 123",
        zip_code: 3000,
        town: "Bern",
        country: "CH",
        number: 123)
      expect(subject.first).to eq [123,
        "Hans Muster",
        "Firma",
        "Eigerplatz 4",
        "Postfach 123",
        nil,
        "3000 Bern",
        nil]
    end
  end
end
