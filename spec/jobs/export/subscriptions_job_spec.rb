# encoding: utf-8

#  Copyright (c) 2017-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Export::SubscriptionsJob do

  subject { Export::SubscriptionsJob.new(format, person.id, list.id, household: true, filename: 'subscription_export') }

  let(:group) { groups(:dachverein) }
  let(:person) { people(:top_leader) }

  let(:list) { Fabricate(:mailing_list, group: group) }

  let(:filename) { AsyncDownloadFile.create_name('subscription_export', person.id) }
  let(:file) { AsyncDownloadFile.from_filename(filename, format) }

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]

    3.times do
      Fabricate(:subscription, mailing_list: list)
    end
  end

  context 'creates an CSV-Export' do
    let(:format) { :csv }

    it 'with salutation, number, correspondence_language, language, canton and additional_information' do
      subject.perform

      lines = file.read.lines
      expect(lines.size).to eq(4) # header and three entries
      expect(lines[0]).to match(/.*Anrede;Korrespondenzsprache;Person Sprache;Kanton;Zusätzliche Angaben;.*/)
    end
  end

end
