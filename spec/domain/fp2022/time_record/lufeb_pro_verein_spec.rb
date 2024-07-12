# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Fp2022::TimeRecord::LufebProVerein do
  let(:year) { 2022 }
  subject { described_class.new(year) }

  let(:group) { groups(:dachverein) }

  it "knows a list of groups to export" do
    expected = [
      "insieme Schweiz",
      "Kanton Bern",
      "Biel-Seeland",
      "Freiburg"
    ]

    expect(subject.vereine.map(&:name)).to match_array expected
    expect(subject.vereine.map(&:name)).to eq expected
  end

  it "has a structured data-object for all groups" do
    list = subject.vereine.map { |verein| subject.lufeb_data_for(verein.id) }

    expect(list).to be_all described_class::Data
  end

  it "has correct data" do
    create_time_record(
      TimeRecord::EmployeeTime,
      auskuenfte: 1,
      gremien: 2,
      beratung_fachhilfeorganisationen: 3,
      lufeb_grundlagen: 4,
      kurse_grundlagen: 5
    )

    create_time_record(
      TimeRecord::VolunteerWithVerificationTime,
      auskuenfte: 5,
      gremien: 4,
      beratung_fachhilfeorganisationen: 3,
      lufeb_grundlagen: 2,
      kurse_grundlagen: 1
    )

    data = subject.lufeb_data_for(group.id)

    expect(data.general).to eq 6
    expect(data.specific).to eq 6
    expect(data.promoting).to eq 6
    expect(data.lufeb_grundlagen).to eq 6
    expect(data.kurse_grundlagen).to eq 6
  end

  private

  def create_time_record(model_name, values)
    model_name.create!(values.merge(group_id: group.id, year: year))
  end
end
