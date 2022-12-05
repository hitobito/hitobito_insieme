# encoding: utf-8

#  Copyright (c) 2012-2017, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

module Fp2020
  describe Export::Tabular::Events::ShortList do

    let(:courses) { [course1] }
    let(:course1) do
      Fabricate(:course, groups: [groups(:be)], motto: 'All for one', cost: 1000,
                application_opening_at: '01.01.2020', application_closing_at: '01.02.2020',
                maximum_participants: 10, external_applications: false, priorization: false,
                leistungskategorie: 'bk', fachkonzept: 'sport_jugend',
                dates: [Fabricate(:fp2020_date)])
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

      Export::Tabular::Events::ShortList.xlsx(courses, 'test group name', '2020')
    end

    private

    def column_widths
      [20,20,3.3,20,2.57,7.43,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,3,3,3,3,3,3,3,3,3,3,3,3,
       20,5.7,9.14,9.14,2.57,3.7,3,7,2.57,2.57,17.14,4.29,3.71,2.57,11.57,3.71,2.57,4.29,4.29,4.29,
       4.29,4.29,4.29,4.29,4.29,6.29,6.29,6.29,2.57,2.57,2.57,2.57,2.57,8.14,8.14,8.14,8.14,8.14,
       2.57,8.14,9.14,8.14,2.54]
    end
  end
end
