#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Event::Participation do
  let(:participation) { event_participations(:top_participant) }

  before do
    # required when migration was run in this same process, after model class got loaded
    # for the first time.
    if Event::Participation.validators_on(:wheel_chair).blank?
      Event::Participation.validates_by_schema only: [:multiple_disability, :wheel_chair,
        :disability]
    end
  end

  it "allows nil values for multiple disability" do
    participation.multiple_disability = true
    expect(participation).to be_valid
    participation.save!
    expect(participation.reload.multiple_disability).to be true

    participation.multiple_disability = nil
    expect(participation).to be_valid
    participation.save!
    expect(participation.reload.multiple_disability).to be nil
  end

  it "does not allow nil values for wheel chair" do
    participation.wheel_chair = false
    expect(participation).to be_valid
    participation.save!
    expect(participation.reload.wheel_chair).to be false

    participation.wheel_chair = nil
    expect(participation).not_to be_valid
  end
end
