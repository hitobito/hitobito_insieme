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
      # trigger address normalization
      person.save!
    end

    it "GET#new uses normal address" do
      get :new, params: {group_id: group.id, invoice: {recipient_id: person.id}}
      expect(response).to be_successful
      expect(assigns(:invoice).recipient_address).to eq("Top Leader\nTeststrasse 23\n3007 Bern")
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
      # rubocop:todo Layout/LineLength
      expect(assigns(:invoice).recipient_address).to eq("Max Mustermann\nMusterweg 2\n8000 Hitobitingen")
      # rubocop:enable Layout/LineLength
    end
  end
end
