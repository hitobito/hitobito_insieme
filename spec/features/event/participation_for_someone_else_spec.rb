# frozen_string_literal: true

#  Copyright (c) 2026, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe "Event participation for someone else", js: true do
  let(:event) { events(:top_course) }
  let(:group) { event.groups.first }
  let!(:someone_else) do
    Fabricate(Group::Aktivmitglieder::Aktivmitglied.name.to_sym, group: groups(:aktiv),
      person: Fabricate(:person, first_name: "Erika", last_name: "Muster")).person
  end

  before do
    event.refresh_participant_counts!
    event.update_columns(waiting_list: true, maximum_participants: event.participant_count)
    sign_in(roles(:regio_leader).person)
  end

  it "assigns the place on a full course, not on the waiting list" do
    expect(event.reload).not_to be_places_available

    visit new_group_event_participation_path(group, event, for_someone_else: true)
    fill_in "Person", with: "Erika"
    find('ul[role="listbox"] li[role="option"]', text: "Erika Muster").click
    click_on "Anmelden"
    expect(page).to have_content "Teilnahme von Erika Muster"

    expect(page).not_to have_content "Auf Warteliste"
    expect(event.reload.participant_count).to eq event.maximum_participants + 1
  end
end
