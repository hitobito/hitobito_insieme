# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::ParticipationCantonCount do

  let(:counts) do
    Event::ParticipationCantonCount.create!
  end

  context '#total' do
    it 'should be 0 without counts' do
      counts.total.should eq 0
    end

    it 'should sum all canton counts' do
      [:ag, :ai, :ar, :be, :bl, :bs, :fr, :ge, :gl, :gr, :ju,
       :lu, :ne, :nw, :ow, :sg, :sh, :so, :sz, :tg, :ti, :ur,
       :vd, :vs, :zg, :zh, :other].each do |attr|
        counts[attr] = 1
      end
      counts.total.should eq 27
    end
  end

end