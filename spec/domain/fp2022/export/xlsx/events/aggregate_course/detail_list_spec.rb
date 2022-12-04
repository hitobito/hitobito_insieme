# encoding: utf-8

#  Copyright (c) 2012-2022, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

module Fp2022
  describe Export::Tabular::Events::AggregateCourse::DetailList do

    let(:courses) { [course1] }
    let(:course1) do
      Fabricate(:course, groups: [groups(:be)], motto: 'All for one', cost: 1000,
                application_opening_at: '01.01.2022', application_closing_at: '01.02.2022',
                maximum_participants: 10, external_applications: false, priorization: false,
                leistungskategorie: 'bk', fachkonzept: 'sport_jugend',
                dates: [Fabricate(:fp2022_date)])
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

      expect_any_instance_of(::Export::Xlsx::Generator)
        .to receive(:data_row_height)
        .with(50)
        .and_call_original

      Export::Tabular::Events::AggregateCourse::DetailList.xlsx(courses, 'test group name', '2022')
    end

    private

    def column_widths
      [
        18, 12.86, 20, 18, 18, 2.57, 2.57, 2.57, 2.57, 2.57, 2.57,
        2.57, 2.57, 2.57, 2.57, 2.57, 2.57, 2.57, 2.57, 2.57, 2.57, 2.57,
        2.57, 2.57, 2.57, 2.57, 2.57, 2.57, 2.57, 2.57, 2.57, 2.57, 2.57,
        2.57, 2.57, 2.57
      ]
    end

  end
end
