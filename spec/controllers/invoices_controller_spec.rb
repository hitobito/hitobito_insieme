#  Copyright (c) 2017, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe InvoicesController do
  let(:group) { groups(:dachverein) }
  let(:person) { people(:top_leader) }

  before { sign_in(person) }

  context "new" do
    before do
      Fabricate(Group::Dachverein::BerechtigungRechnungen.sti_name, group:, person:)
    end

    it "GET#new uses normal address" do
      get :new, params: {
        group_id: group.id,
        invoice: {recipient_type: "Person", recipient_id: person.id}
      }
      expect(response).to be_successful
      expect(assigns(:invoice).recipient_name).to eq("Top Leader")
      expect(assigns(:invoice).recipient_street).to eq("Teststrasse")
      expect(assigns(:invoice).recipient_housenumber).to eq("23")
      expect(assigns(:invoice).recipient_zip_code).to eq("3007")
      expect(assigns(:invoice).recipient_town).to eq("Bern")
    end

    it "GET#new uses invoice address if present" do
      Fabricate(:additional_address,
        contactable: person,
        category: contact_account_categories(:additional_address_person_invoices),
        uses_contactable_name: false,
        first_name: "Max",
        last_name: "Mustermann",
        street: "Alte Bahnhofstrasse",
        housenumber: "2",
        zip_code: "8000",
        town: "Hitobitingen",
        country: "CH")
      get :new, params: {
        group_id: group.id,
        invoice: {recipient_type: "Person", recipient_id: person.id}
      }
      expect(response).to be_successful
      expect(assigns(:invoice).recipient_name).to eq("Max Mustermann")
      expect(assigns(:invoice).recipient_street).to eq("Alte Bahnhofstrasse")
      expect(assigns(:invoice).recipient_housenumber).to eq("2")
      expect(assigns(:invoice).recipient_zip_code).to eq("8000")
      expect(assigns(:invoice).recipient_town).to eq("Hitobitingen")
    end
  end
end
