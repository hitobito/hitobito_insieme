require 'spec_helper'

describe Export::Xlsx::CostAccounting::List do

  let(:group) { groups(:aktiv) }
  let(:values) { CostAccounting::Table.new(group, '2010').reports.values }

  it 'exports cost accounting list as xlsx' do

    expect_any_instance_of(Axlsx::Worksheet)
      .to receive(:add_row)
      .exactly(30).times
      .and_call_original

    Export::Xlsx::CostAccounting::List.export(values, 'test group name', '2014')

  end

end