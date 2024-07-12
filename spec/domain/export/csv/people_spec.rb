#  Copyright (c) 2012-2024, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"
require "csv"

describe Export::Tabular::People do
  let(:person) { people(:top_leader) }
  let(:simple_headers) do
    %w[Vorname Nachname Übername Firmenname Firma Haupt-E-Mail Adresse PLZ Ort Land
      Hauptebene Rollen Personnr. Anrede Korrespondenzsprache] +
      [
        "Anrede Korrespondenzadresse allgemein",
        "Vorname Korrespondenzadresse allgemein",
        "Nachname Korrespondenzadresse allgemein",
        "Firmenname Korrespondenzadresse allgemein",
        "Firma Korrespondenzadresse allgemein",
        "Adresse Korrespondenzadresse allgemein",
        "PLZ Korrespondenzadresse allgemein",
        "Ort Korrespondenzadresse allgemein",
        "Land Korrespondenzadresse allgemein",

        "Anrede Rechnungsadresse allgemein",
        "Vorname Rechnungsadresse allgemein",
        "Nachname Rechnungsadresse allgemein",
        "Firmenname Rechnungsadresse allgemein",
        "Firma Rechnungsadresse allgemein",
        "Adresse Rechnungsadresse allgemein",
        "PLZ Rechnungsadresse allgemein",
        "Ort Rechnungsadresse allgemein",
        "Land Rechnungsadresse allgemein",

        "Anrede Korrespondenzadresse Kurs",
        "Vorname Korrespondenzadresse Kurs",
        "Nachname Korrespondenzadresse Kurs",
        "Firmenname Korrespondenzadresse Kurs",
        "Firma Korrespondenzadresse Kurs",
        "Adresse Korrespondenzadresse Kurs",
        "PLZ Korrespondenzadresse Kurs",
        "Ort Korrespondenzadresse Kurs",
        "Land Korrespondenzadresse Kurs",

        "Anrede Rechnungsadresse Kurs",
        "Vorname Rechnungsadresse Kurs",
        "Nachname Rechnungsadresse Kurs",
        "Firmenname Rechnungsadresse Kurs",
        "Firma Rechnungsadresse Kurs",
        "Adresse Rechnungsadresse Kurs",
        "PLZ Rechnungsadresse Kurs",
        "Ort Rechnungsadresse Kurs",
        "Land Rechnungsadresse Kurs"
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
      person.correspondence_general_same_as_main = false
      person.correspondence_general_first_name = "Töp"
      person.correspondence_general_country = "FR"
      person

      person.reference_person_number = "123"

      person.disabled_person_reference = true
      person.disabled_person_first_name = "George"
      person.disabled_person_last_name = "Harrison"
      person.disabled_person_address = "Abbey Road 3"
      person.disabled_person_zip_code = 1234
      person.disabled_person_town = "London"
      person.disabled_person_birthday = "25.02.1943"

      person.save!
    end

    let(:list) { [person] }
    let(:data) { Export::Tabular::People::PeopleAddress.csv(list) }
    let(:data_without_bom) { data.gsub(Regexp.new("^#{Export::Csv::UTF8_BOM}"), "") }
    let(:csv) { CSV.parse(data_without_bom, headers: true, col_sep: Settings.csv.separator) }

    subject { csv }

    context "export" do
      its(:headers) do
        is_expected.to match_array(simple_headers)
        is_expected.to match_array(simple_headers)
      end

      context "first row" do
        subject { csv[0] }

        its(["Vorname"]) { is_expected.to eq person.first_name }
        its(["Nachname"]) { is_expected.to eq person.last_name }
        its(["Haupt-E-Mail"]) { is_expected.to eq person.email }
        its(["Ort"]) { is_expected.to eq person.town }
        its(["Land"]) { is_expected.to eq person.country_label }
        its(["Vorname Korrespondenzadresse allgemein"]) { is_expected.to eq "Töp" }
        its(["Land Korrespondenzadresse allgemein"]) { is_expected.to eq "Frankreich" }
        its(["Rollen"]) { is_expected.to eq "Geschäftsführung insieme Schweiz" }
      end
    end

    context "export_full" do
      let(:data) { Export::Tabular::People::PeopleFull.csv(list) }

      its(:headers) { is_expected.to include("Anrede") }
      its(:headers) { is_expected.to include("AHV Nummer") }
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
