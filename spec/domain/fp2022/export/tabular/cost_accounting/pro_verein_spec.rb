# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Fp2022::Export::Tabular::CostAccounting::ProVerein do
  include Featureperioden::Domain

  let(:year) { 2022 }
  let(:stats) { fp_class("CostAccounting::ProVerein").new(year) }

  subject { described_class.new(stats) }

  describe "#group_row" do
    it "includes group name, bsv_number, and id as first three elements" do
      group = groups(:be)
      group_row = subject.send(:group_row, group)

      expect(group_row[0]).to eq group.name
      expect(group_row[1]).to eq group.bsv_number
      expect(group_row[2]).to eq group.id
    end

    it "pads remaining elements with nil" do
      group = groups(:be)
      group_row = subject.send(:group_row, group)
      label_keys_count = subject.send(:label_keys).count

      # First 3 elements are: name, bsv_number, id
      # Remaining should be nil
      expect(group_row.size).to eq label_keys_count
      expect(group_row[3..]).to be_all nil if group_row.size > 3
    end
  end
end
