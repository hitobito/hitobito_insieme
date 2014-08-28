require 'spec_helper'

describe CostAccounting::Table do

  let(:group) { groups(:be) }
  let(:table) { CostAccounting::Table.new(group, 2014) }

  context '#value_of' do
    context 'is lazy initialized' do
      it 'without records' do
        table.value_of('lohnaufwand', 'lufeb').should be_nil
      end
    end
  end
end
