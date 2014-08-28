require 'spec_helper'

describe CostAccountingRecord do

  let(:group) { groups(:be) }

  context 'validation' do
    it 'is fine with empty fields' do
      r = CostAccountingRecord.new(group: group, year: 2014, report: 'lohnaufwand')
      r.should be_valid
    end

    it 'fails for invalid report' do
      r = CostAccountingRecord.new(group: group, year: 2014, report: 'foo')
      r.should_not be_valid
    end

    it 'fails for invalid group' do
      r = CostAccountingRecord.new(group: groups(:passiv), year: 2014, report: 'lohnaufwand')
      r.should_not be_valid
    end
  end

end
