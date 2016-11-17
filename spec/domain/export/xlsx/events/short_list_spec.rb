require 'spec_helper'

describe Export::Xlsx::Events::ShortList do

  let(:courses) { [course1] }
  let(:course1) do
    Fabricate(:course, groups: [groups(:be)], motto: 'All for one', cost: 1000,
              application_opening_at: '01.01.2000', application_closing_at: '01.02.2000',
              maximum_participants: 10, external_applications: false, priorization: false,
              leistungskategorie: 'bk')
  end

  it 'exports short events list as xlsx' do

    expect_any_instance_of(Axlsx::Worksheet)
      .to receive(:add_row)
      .exactly(5).times
      .and_call_original

    expect_any_instance_of(Axlsx::Worksheet)
      .to receive(:column_widths)
      .with(*column_widths)
      .and_call_original

    expect_any_instance_of(Export::Xlsx::Generator)
      .to receive(:data_row_height)
      .with(130)
      .and_call_original

    Export::Xlsx::Events::ShortList.export(courses, 'test group name', '2014')
  end

  private

  def column_widths
    [12, 20, 3.3, 40, 2.57, 7.43]+
      Array.new(9, 2.57)+
      Array.new(12, 3)+
      [40, 5.7, 9.14, 9.14, 2.57, 3.7, 3,7]+
      [2.57, 2.57, 17.14, 4.29, 3.71, 2.57]+
      [11.57, 3.71, 2.57, 4.29, 3.29]+
      Array.new(3, 2.57)+
      [5.29, 2.57, 2.57, 6.29]+
      Array.new(7, 2.57)+
      [8.14, 5.71, 7.14, 8.14, 2.57, 2.57]+
      [8.14, 9.14, 5.71, 2.54]
  end
end
