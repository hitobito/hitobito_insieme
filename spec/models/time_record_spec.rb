require 'spec_helper'

describe TimeRecord do

  context '#total' do
    it 'is 0 for new record' do
      TimeRecord.new.total.should eq(0)
    end

    it 'is the sum of the values set' do
      TimeRecord.new(blockkurse: 3, mittelbeschaffung: 2, newsletter: 1).total.should eq(6)
    end
  end

end
