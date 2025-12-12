# frozen_string_literal: true

# Copyright (c) 2012-2025, insieme Schweiz. This file is part of
# hitobito_insieme and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https://github.com/hitobito/hitobito_insieme.
#
require "spec_helper"

describe "groups/_attrs_insieme.html.haml" do
  let(:dom) {
    render
    Capybara::Node::Simple.new(@rendered)
  }
  let(:current_user) { people(:top_leader) }

  before do
    allow(view).to receive(:entry).and_return(group.decorate)
  end

  let(:dom) { Capybara::Node::Simple.new(@rendered) }

  let(:group) { groups(:dachverein) }

  it "renders founded_on field" do
    render
    expect(dom).to have_css ".labeled-grid:nth-of-type(3) dt", text: "BSV-Nummer"
    expect(dom).to have_css ".labeled-grid:nth-of-type(4) dt", text: "Insieme-ID"
    expect(dom).to have_css ".labeled-grid:nth-of-type(4) dd", text: group.id
    expect(dom).to have_css ".labeled-grid:nth-of-type(5) dt", text: "Kanton"
  end
end
