#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: cost_accounting_records
#
#  id                          :integer          not null, primary key
#  group_id                    :integer          not null
#  year                        :integer          not null
#  report                      :string(255)      not null
#  aufwand_ertrag_fibu         :decimal(12, 2)
#  abgrenzung_fibu             :decimal(12, 2)
#  abgrenzung_dachorganisation :decimal(12, 2)
#  raeumlichkeiten             :decimal(12, 2)
#  verwaltung                  :decimal(12, 2)
#  beratung                    :decimal(12, 2)
#  treffpunkte                 :decimal(12, 2)
#  blockkurse                  :decimal(12, 2)
#  tageskurse                  :decimal(12, 2)
#  jahreskurse                 :decimal(12, 2)
#  lufeb                       :decimal(12, 2)
#  mittelbeschaffung           :decimal(12, 2)
#  aufteilung_kontengruppen    :text
#

require "spec_helper"

describe CostAccountingRecord do
  let(:group) { groups(:be) }

  context "validation" do
    it "is fine with empty fields" do
      r = CostAccountingRecord.new(group: group, year: 2014, report: "lohnaufwand")
      expect(r).to be_valid
    end

    it "fails for invalid report" do
      r = CostAccountingRecord.new(group: group, year: 2014, report: "foo")
      expect(r).not_to be_valid
    end

    it "fails for invalid group" do
      r = CostAccountingRecord.new(group: groups(:aktiv), year: 2014, report: "lohnaufwand")
      expect(r).not_to be_valid
    end
  end
end
