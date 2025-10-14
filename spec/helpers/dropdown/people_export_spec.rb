#  Copyright (c) 2014, Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe "Insieme::Dropdown::PeopleExport" do
  include FormatHelper
  include LayoutHelper
  include UtilityHelper

  let(:user) { people(:top_leader) }
  let(:dropdown) do
    Dropdown::PeopleExport.new(self,
      user,
      {controller: "people", group_id: groups(:dachverein).id},
      households: false, labels: true)
  end
  let!(:label_format) { Fabricate(:label_format) }

  subject { Capybara::Node::Simple.new(dropdown.to_s) }

  def can?(*args)
    true
  end

  it "renders dropdown" do
    is_expected.to have_content "Export"
    menu = subject.find(".btn-group > ul.dropdown-menu")
    expect(menu).to be_present
    top_menu_entries = menu.all("> li > a").map(&:text)
    expect(top_menu_entries).to match_array(["CSV", "Etiketten", "Excel", "PDF", "vCard"])
    # rubocop:todo Layout/LineLength
    label_format_submenu = menu.all("> li > a:contains('Etiketten') ~ ul.dropdown-menu.submenu").first
    # rubocop:enable Layout/LineLength
    expect(label_format_submenu).to be_present
  end
end
