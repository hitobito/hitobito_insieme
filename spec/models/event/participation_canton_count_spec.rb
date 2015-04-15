# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: event_participation_canton_counts
#
#  id    :integer          not null, primary key
#  ag    :integer
#  ai    :integer
#  ar    :integer
#  be    :integer
#  bl    :integer
#  bs    :integer
#  fr    :integer
#  ge    :integer
#  gl    :integer
#  gr    :integer
#  ju    :integer
#  lu    :integer
#  ne    :integer
#  nw    :integer
#  ow    :integer
#  sg    :integer
#  sh    :integer
#  so    :integer
#  sz    :integer
#  tg    :integer
#  ti    :integer
#  ur    :integer
#  vd    :integer
#  vs    :integer
#  zg    :integer
#  zh    :integer
#  other :integer
#

require 'spec_helper'

describe Event::ParticipationCantonCount do

  let(:counts) do
    Event::ParticipationCantonCount.new
  end

  context '#total' do
    it 'should be 0 without counts' do
      expect(counts.total).to eq 0
    end

    it 'should sum all canton counts' do
      Cantons::SHORT_NAMES.each do |attr|
        counts[attr] = 1
      end
      expect(counts.total).to eq 27
    end
  end

end
