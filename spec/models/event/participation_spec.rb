# encoding: utf-8

#  Copyright (c) 2014 Insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::Participation do

  let(:participation) { event_participations(:top_participant) }

  it 'allows nil values for multiple disability' do
    participation.multiple_disability = true
    participation.should be_valid
    participation.save!
    participation.reload.multiple_disability.should be true

    participation.multiple_disability = nil
    participation.should be_valid
    participation.save!
    participation.reload.multiple_disability.should be nil
  end

  it 'does not allow nil values for wheel chair' do
    participation.wheel_chair = false
    participation.should be_valid
    participation.save!
    participation.reload.wheel_chair.should be false

    participation.wheel_chair = nil
    participation.should_not be_valid
  end

end
