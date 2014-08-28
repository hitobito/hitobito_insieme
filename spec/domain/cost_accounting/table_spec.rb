require 'spec_helper'

describe CostAccounting::Table do

  let(:group) { groups(:be) }
  let(:table) { CostAccounting::Table.new(group, 2014) }

  context '#value_of' do
    context 'is lazy initialized' do

      CostAccounting::Table::REPORTS.each do |key, report|
        CostAccounting::Report::Base::FIELDS.each do |field|
          context "for #{key}-#{field}" do
            it 'without records' do
              table.value_of(key, field).to_d.should eq(0.0)
            end
          end
        end
      end

    end
  end
end
