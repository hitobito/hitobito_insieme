# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Fp2020::TimeRecord::OrganisationsDaten do
  let(:year) { 2020 }
  subject { described_class.new(year) }

  let(:group) { groups(:dachverein) }

  it 'knows a list of groups to export' do
    expected = [
      'insieme Schweiz',
      'Kanton Bern',
      'Biel-Seeland',
      'Freiburg'
    ]

    expect(subject.vereine.map(&:name)).to match_array expected
    expect(subject.vereine.map(&:name)).to eq expected
  end

  it 'has a structured data-object for all groups' do
    list = subject.vereine.map { |verein| subject.data_for(verein) }

    expect(list).to be_all described_class::Data
  end

  it 'has correct data' do
    create_cost_accounting_report('honorare', aufwand_ertrag_fibu: 123_500) # 0.5 FTE
    create_time_report(TimeRecord::EmployeeTime, {})
      .create_employee_pensum(paragraph_74: 0.5) # 0.5 FTE Art74
    create_time_report(
      TimeRecord::VolunteerWithoutVerificationTime,
      nicht_art_74_leistungen: 475 # 0.25 FTE
    )
    create_time_report(
      TimeRecord::VolunteerWithVerificationTime,
      nicht_art_74_leistungen: 475, # 0.25 FTE
      beratung: 2850 # 1.5 FTE Art74
    )

    data = subject.data_for(group)

    expect(data.angestellte_insgesamt).to be_within(0.01).of(1.0)
    expect(data.angestellte_art_74).to    be_within(0.01).of(0.5)
    expect(data.freiwillige_insgesamt).to be_within(0.01).of(2.0)
    expect(data.freiwillige_art_74).to    be_within(0.01).of(1.5)
  end

  it 'knows the BSV-hours in a year' do
    expect(subject.send :bsv_hours_per_year).to eq 1900
  end

  it 'knows the assumed hourly rate' do
    expect(subject.send :assumed_hourly_rate).to eq 130
  end

  it 'knows the conversion denominator between external fte and internal fte' do
    expect(subject.send :honorar_zu_mitarbeiter_teiler).to eq (1900 * 130)
  end

  private

  def create_time_report(model, values)
    model.create!(values.merge(group_id: group.id, year: year))
  end

  def create_cost_accounting_report(name, values)
    CostAccountingRecord.create!(
      values.merge(group_id: group.id, year: year, report: name)
    )
  end
end
