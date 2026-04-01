# frozen_string_literal: true

#  Copyright (c) 2026, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme

RSpec.shared_examples "cost accounting pdf export" do
  let(:group) { groups(:be) }
  let(:table) { fp_class("CostAccounting::Table").new(group, year) }
  let(:reports) { table.visible_reports.values }

  subject(:pdf_export) { described_class.new(reports, group.name, year) }

  describe "#generate" do
    it "returns a valid PDF" do
      result = pdf_export.generate

      expect(result).to be_present
      expect(result[0..3]).to eq("%PDF")
    end

    it "contains the group name and year" do
      result = pdf_export.generate
      text = PDF::Inspector::Text.analyze(result)

      expect(text.strings).to include(group.name)
      expect(text.strings.join).to include(year.to_s)
    end
  end
end
