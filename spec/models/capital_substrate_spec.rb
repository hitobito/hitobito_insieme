# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe CapitalSubstrate do
  let(:defaults) do
    {group_id: groups(:dachverein).id, year: 2020}
  end

  subject { described_class.new(defaults) }

  it "can find the newest previous sum" do
    described_class.create(defaults.merge({
      year: 2019,
      previous_substrate_sum: 1337.42
    }))

    expect(subject.newest_previous_sum).to eq 1337.42
  end

  it "looks in the past" do
    described_class.create(defaults.merge({
      year: 2019,
      previous_substrate_sum: 1337.42
    }))

    described_class.create(defaults.merge({
      year: 2022,
      previous_substrate_sum: 2342.00
    }))

    expect(subject.newest_previous_sum).to eq 1337.42
  end

  it "skips entries without sum" do
    described_class.create(defaults.merge({
      year: 2018,
      previous_substrate_sum: 1337.42
    }))

    described_class.create(defaults.merge({
      year: 2019,
      previous_substrate_sum: nil # default, but this is the test
    }))

    expect(subject.newest_previous_sum).to eq 1337.42
  end

  it "selects the most recent one" do
    described_class.create(defaults.merge({
      year: 2018,
      previous_substrate_sum: 2342.00
    }))

    described_class.create(defaults.merge({
      year: 2019,
      previous_substrate_sum: 1337.42
    }))

    expect(subject.newest_previous_sum).to eq 1337.42
  end

  it "considers only the own group" do
    described_class.create(defaults.merge({
      year: 2018,
      group_id: groups(:dachverein).id, # in the defaults above, this is the test for this
      previous_substrate_sum: 1337.42
    }))

    described_class.create(defaults.merge({
      year: 2019,
      group_id: groups(:be).id,
      previous_substrate_sum: 2342.00
    }))

    expect(subject.newest_previous_sum).to eq 1337.42
  end

  it "returns nil if nothing is found" do
    expect(described_class.count).to be_zero
    expect(subject.newest_previous_sum).to be_nil
  end
end
