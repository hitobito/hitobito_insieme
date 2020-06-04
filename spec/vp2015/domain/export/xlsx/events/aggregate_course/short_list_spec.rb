# encoding: utf-8

#  Copyright (c) 2012-2017, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

module Vp2015
  describe Export::Tabular::Events::AggregateCourse::ShortList do

    let(:courses) { [course1] }
    let(:course1) do
      Fabricate(:course, groups: [groups(:be)], motto: 'All for one', cost: 1000,
                application_opening_at: '01.01.2000', application_closing_at: '01.02.2000',
                maximum_participants: 10, external_applications: false, priorization: false,
                leistungskategorie: 'bk', fachkonzept: 'sport_jugend')
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

      expect_any_instance_of(::Export::Xlsx::Generator)
        .to receive(:data_row_height)
        .with(130)
        .and_call_original

      Export::Tabular::Events::AggregateCourse::ShortList.xlsx(courses, 'test group name', '2014')
    end

    private

    def column_widths
      [18,12.86,20,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,
       2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,17.14,4.29,3.71,2.57,14,4.29,4.29,7.5,7.5,7.5,7.5,
       7.5,7.5,7.5,7.5,7.5,7.5,7.5,7.5,7.5,7.5,7.5,7.5,8.5,8.5,8.5,8.5,8.5,8.5,8.5,8.5,7.5,3.13]
    end
  end
end
