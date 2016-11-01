require 'spec_helper'

describe Export::Xlsx::Events::AggregateCourse::DetailList do

  let(:courses) { [course1] }
  let(:course1) do
    Fabricate(:course, groups: [groups(:be)], motto: 'All for one', cost: 1000,
              application_opening_at: '01.01.2000', application_closing_at: '01.02.2000',
              maximum_participants: 10, external_applications: false, priorization: false,
              leistungskategorie: 'bk')
  end

  it 'exports detail events list as xlsx' do

    expect_any_instance_of(Axlsx::Worksheet)
      .to receive(:add_row)
      .exactly(5).times
      .and_call_original

    expect_any_instance_of(Axlsx::Worksheet)
      .to receive(:column_widths)
      .with(*column_widths)
      .and_call_original

    Export::Xlsx::Events::AggregateCourse::DetailList.export(courses, 'test group name', '2014')
  end

  private

  def column_widths
    [18, 12.86, 40]+
      Array.new(24, 2.57)+
      [17.14, 4.29, 3.71, 2.57, 14]+
      Array.new(18, 4.29)+
      Array.new(9, 7.5)+
      [3.13]
  end
end
