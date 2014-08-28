require 'spec_helper'

describe CostAccounting::Report::Base do

  let(:year) { 2014 }
  let(:group) { groups(:be) }
  let(:table) { CostAccounting::Table.new(group, year) }
  let(:report) { CostAccounting::Report::Lohnaufwand.new(table) }

  before do
    CostAccountingRecord.create!(group_id: group.id,
                                 year: year,
                                 report: 'lohnaufwand',
                                 aufwand_ertrag_fibu: 1000,
                                 abgrenzung_fibu: 50)
  end

  context '#aufwand_ertrag_ko_re' do
    it 'is calculated correctly' do
      report.aufwand_ertrag_ko_re.should eq(950.0)
    end
  end

  context '#total' do
    it 'is calculated correctly' do
      report.total.should eq(0.0)
    end
  end

  context '#kontrolle' do
    it 'is calculated correctly' do
      report.kontrolle.should eq(-950.0)
    end
  end

  context 'basic accessors' do
    it 'return nil' do
      report.raeumlichkeiten.should be_nil
    end
  end

end
