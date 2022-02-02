# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Vp2021::CostAccounting::Report::TotalUmlagen do
  subject { report }

  let(:year) { 2021 }
  let(:group) { groups(:be) }
  let(:table) { vp_class('CostAccounting::Table').new(group, year) }
  let(:report) { table.reports.fetch('total_umlagen') }

  context 'gemeinkosten_quota' do
    context 'in a verein with employees' do
      before do
        create_employee_time(
            verwaltung: 50,
            mittelbeschaffung: 30,

            beratung: 10,
            treffpunkte: 50,
            blockkurse: 20,
            tageskurse: 20,

            nicht_art_74_leistungen: 10
        )

        create_report('lohnaufwand',
          aufwand_ertrag_fibu: 10_000,
          beratung: 1_000,
          treffpunkte: 5_000,
          blockkurse: 2_000,
          tageskurse: 2_000
        )
        create_report(
          'sozialversicherungsaufwand',
          aufwand_ertrag_fibu: 2000
        )

        described_class.send :public, :gemeinkosten_quota
      end

      it 'uses personalaufwand' do
        is_expected.to receive(:total_personalaufwand_for_all_topics)
                       .and_call_original

        subject.treffpunkte
      end

      it 'has the correct quota' do
        expect(subject.gemeinkosten_quota('treffpunkte'))
          .to be_within(0.01).of(0.5)
      end
    end

    context 'in a verein without employees' do
      before do
        create_report(
          'uebriger_sachaufwand',
          beratung: 700,
        )

        create_course_record(
          'tp', 'treffpunkt',
          uebriges: 300
        )

        described_class.send :public, :gemeinkosten_quota
      end

      it 'uses direktkosten' do
        is_expected.to receive(:total_direktkosten_for_all_topics)
                       .and_call_original

        subject.beratung
      end

      it 'has the correct quota' do
        expect(subject.gemeinkosten_quota('treffpunkte'))
          .to be_within(0.01).of(0.3)
      end
    end
  end

  it 'sets unused fields to nil' do
    expect(report.aufwand_ertrag_ko_re).to be_nil
  end

  private

  def create_report(name, values)
    CostAccountingRecord.create!(values.merge(group_id: group.id,
                                              year: year,
                                              report: name))
  end

  def create_employee_time(values)
    TimeRecord::EmployeeTime.create!(values.merge(
      group_id: group.id,
      year: year
    ))
  end

  def create_course_record(lk, fachkonzept, values)
    Event::CourseRecord.create!(values.merge(
      event: Fabricate(:course,
                       groups: [group],
                       leistungskategorie: lk, fachkonzept: fachkonzept,
                       dates_attributes: [{ start_at: Date.new(year, 10, 1) }]),
      year: year
    ))
  end
end
