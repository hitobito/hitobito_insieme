# encoding: utf-8

#  Copyright (c) 2012-2017, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Export::Tabular::CostAccounting::List do

  let(:year) { 2014 }
  let(:group) { groups(:aktiv) }
  let(:values) { vp_class('CostAccounting::Table').new(group, year).reports.values }

  it 'exports cost accounting list as xlsx' do
    expect_any_instance_of(Axlsx::Worksheet)
      .to receive(:column_widths)
      .with(*column_widths)
      .and_call_original

    expect_any_instance_of(Axlsx::Worksheet)
      .to receive(:add_row)
      .exactly(30).times
      .and_call_original

    Export::Tabular::CostAccounting::List.xlsx(values, 'test group name', year)
  end

  private

  def column_widths
    [57.62, nil, nil, nil, nil, 3]
  end

end
