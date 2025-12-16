#  Copyright (c) 2017, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe InvoicesController do
  let(:group) { groups(:dachverein) }
  let(:person) { people(:top_leader) }
  let(:invoice) { invoices(:invoice) }

  before { sign_in(person) }

  context "new" do
    before do
      Fabricate(Group::Dachverein::BerechtigungRechnungen.sti_name, group:, person:)
      # trigger address normalization
      person.save!
    end

    it "GET#new uses normal address" do
      get :new, params: {group_id: group.id, invoice: {recipient_id: person.id}}
      expect(response).to be_successful
      expect(assigns(:invoice).recipient_name).to eq("Top Leader")
      expect(assigns(:invoice).recipient_street).to eq("Teststrasse")
      expect(assigns(:invoice).recipient_housenumber).to eq("23")
      expect(assigns(:invoice).recipient_zip_code).to eq("3007")
      expect(assigns(:invoice).recipient_town).to eq("Bern")
    end

    it "GET#new uses billing_general address if different from normal address" do
      person.update(
        billing_general_same_as_main: false,
        billing_general_first_name: "Max",
        billing_general_last_name: "Mustermann",
        billing_general_address: "Musterweg 2",
        billing_general_zip_code: "8000",
        billing_general_town: "Hitobitingen"
      )
      get :new, params: {group_id: group.id, invoice: {recipient_id: person.id}}
      expect(response).to be_successful
      expect(assigns(:invoice).recipient_name).to eq("Max Mustermann")
      expect(assigns(:invoice).recipient_street).to eq("Musterweg")
      expect(assigns(:invoice).recipient_housenumber).to eq("2")
      expect(assigns(:invoice).recipient_zip_code).to eq("8000")
      expect(assigns(:invoice).recipient_town).to eq("Hitobitingen")
    end
  end
end
