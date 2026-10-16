#  Copyright (c) 2012-2024, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"
require "csv"

describe Export::Tabular::People do
  let(:person) { people(:top_leader) }
  let(:simple_headers) do
    %w[Vorname Nachname Übername Firmenname Firma Haupt-E-Mail PLZ Ort Land
      Hausnummer Postfach Strasse
      Hauptebene Rollen Personnr. Anrede Korrespondenzsprache] +
      ["c/o-Adresse"] +
      [
        "Weitere Adresse Andere",
        "Weitere Adresse Arbeit",
        "Weitere Adresse Beistand",
        "Weitere Adresse Mutter",
        "Weitere Adresse Rechnungsadresse",
        "Weitere Adresse Vater",
        "Weitere Adresse Wohngruppe",
        "Weitere Adresse Wohnheim"
      ] +
      [
        "Telefonnummer Andere",
        "Telefonnummer Arbeit",
        "Telefonnummer Beistand",
        "Telefonnummer Mobil",
        "Telefonnummer Festnetz",
        "Telefonnummer Mutter",
        "Telefonnummer Vater",
        "Telefonnummer Wohngruppe",
        "Telefonnummer Wohnheim",
        "Weitere E-Mail Rechnungsadresse",
        "Weitere E-Mail Andere",
        "Weitere E-Mail Arbeit",
        "Weitere E-Mail Beistand",
        "Weitere E-Mail Mutter",
        "Weitere E-Mail Privat",
        "Weitere E-Mail Vater",
        "Weitere E-Mail Wohngruppe",
        "Weitere E-Mail Wohnheim"
      ]
  end

  describe Export::Tabular::People do
    before do
      Fabricate(Group::Aktivmitglieder::Aktivmitglied.sti_name.to_sym,
        group: groups(:aktiv),
        person: Fabricate(:person, number: "123", first_name: "John", last_name: "Lennon",
          street: "Bank Street", housenumber: "105",
          zip_code: 1234, town: "New York",
          additional_information: "English musician"))

      person.country = "US"
      person.zip_code = 60601

      person.reference_person_number = "123"

      person.disabled_person_reference = true
      person.disabled_person_first_name = "George"
      person.disabled_person_last_name = "Harrison"
      person.disabled_person_address = "Abbey Road 3"
      person.disabled_person_zip_code = 1234
      person.disabled_person_town = "London"
      person.disabled_person_birthday = "25.02.1943"

      person.save!

      Fabricate(:additional_address,
        contactable: person,
        category: contact_account_categories(:additional_address_person_vater),
        public: true,
        uses_contactable_name: false,
        first_name: "Töp",
        last_name: "Vater",
        street: "Rue de Rivoli",
        housenumber: "1",
        zip_code: "75001",
        town: "Paris",
        country: "FR")
    end

    let(:list) { [person] }
    let(:data) { Export::Tabular::People::PeopleAddress.csv(list) }
    let(:data_without_bom) { data.gsub(Regexp.new("^#{Export::Csv::UTF8_BOM}"), "") }
    let(:csv) { CSV.parse(data_without_bom, headers: true, col_sep: Settings.csv.separator) }

    subject { csv }

    context "export" do
      its(:headers) do
        is_expected.to match_array(simple_headers)
      end

      context "first row" do
        subject { csv[0] }

        its(["Vorname"]) { is_expected.to eq person.first_name }
        its(["Nachname"]) { is_expected.to eq person.last_name }
        its(["Haupt-E-Mail"]) { is_expected.to eq person.email }
        its(["Ort"]) { is_expected.to eq person.town }
        its(["Land"]) { is_expected.to eq person.country_label }
        its(["Weitere Adresse Vater"]) do
          is_expected.to eq "Töp Vater, Rue de Rivoli 1, 75001 Paris, Frankreich"
        end
        its(["Rollen"]) { is_expected.to eq "Berechtigung Admin insieme Schweiz" }
      end
    end

    context "export_full" do
      let(:data) { Export::Tabular::People::PeopleFull.csv(list) }

      its(:headers) { is_expected.to include("Anrede") }
      its(:headers) { is_expected.to include("Bezugspersonennr.") }
      its(:headers) { is_expected.to include("Vorname Bezugsperson") }
      its(:headers) { is_expected.to include("Nachname Bezugsperson") }
      its(:headers) { is_expected.to include("Adresse Bezugsperson") }
      its(:headers) { is_expected.to include("PLZ Bezugsperson") }
      its(:headers) { is_expected.to include("Ort Bezugsperson") }
      its(:headers) { is_expected.to include("Aktivmitgliedschaft Rollen Bezugsperson") }
      its(:headers) { is_expected.to include("Zusätzliche Angaben Bezugsperson") }

      context "first row" do
        subject { csv[0] }

        its(["Vorname"]) { is_expected.to eq "Top" }
        its(["Nachname"]) { is_expected.to eq "Leader" }

        its(["Vorname Zugehörige Person mit Behinderung"]) { is_expected.to eq "George" }
        its(["Nachname Zugehörige Person mit Behinderung"]) { is_expected.to eq "Harrison" }
        its(["Adresse Zugehörige Person mit Behinderung"]) { is_expected.to eq "Abbey Road 3" }
        its(["PLZ Zugehörige Person mit Behinderung"]) { is_expected.to eq "1234" }
        its(["Ort Zugehörige Person mit Behinderung"]) { is_expected.to eq "London" }

        its(["Bezugspersonennr."]) { is_expected.to eq "123" }
        its(["Vorname Bezugsperson"]) { is_expected.to eq "John" }
        its(["Nachname Bezugsperson"]) { is_expected.to eq "Lennon" }
        its(["Adresse Bezugsperson"]) { is_expected.to eq "Bank Street 105" }
        its(["PLZ Bezugsperson"]) { is_expected.to eq "1234" }
        its(["Ort Bezugsperson"]) { is_expected.to eq "New York" }
        its(["Aktivmitgliedschaft Rollen Bezugsperson"]) do
          is_expected.to eq "Biel-Seeland / Aktivmitglieder: Aktivmitglied"
        end
        its(["Zusätzliche Angaben Bezugsperson"]) { is_expected.to eq "English musician" }
      end
    end
  end
end
