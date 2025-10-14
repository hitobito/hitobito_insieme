#  Copyright (c) 2017-2024, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Export::SubscriptionsJob do
  let(:group) { groups(:dachverein) }
  let(:person) { people(:top_leader) }

  let(:list) { Fabricate(:mailing_list, group: group) }

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join("db", "seeds")]

    3.times do
      Fabricate(:subscription, mailing_list: list)
    end
  end

  context "has the correct data for the export" do
    subject {
      Export::SubscriptionsJob.new(:csv, person.id, list.id, household: true,
        filename: "subscription_export")
    }

    # rubocop:todo Layout/LineLength
    it "with salutation, number, correspondence_language, language, canton and additional_information" do
      # rubocop:enable Layout/LineLength
      data = subject.data

      lines = data.lines
      expect(lines.size).to eq(4) # header and three entries
      # rubocop:todo Layout/LineLength
      expect(lines[0]).to match(/.*Anrede;Korrespondenzsprache;Person Sprache;Kanton;Zusätzliche Angaben;.*/)
      # rubocop:enable Layout/LineLength
    end
  end
end
