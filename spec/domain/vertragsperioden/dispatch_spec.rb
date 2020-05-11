# frozen_string_literal: true

#  Copyright (c) 2020, Insieme Schweiz. This file is part of hitobito_insieme
#  and licensed under the Affero General Public License version 3 or later. See
#  the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Vertragsperioden::Dispatch do
  subject { described_class.new(year) }
  let(:year) { 2020 }

  context 'can determine the correct period' do
    it 'for 2014 and earlier, it is 2015' do
      expect(described_class.new(2014).determine).to be 2015
    end

    it 'for 2015, it is 2015' do
      expect(described_class.new(2015).determine).to be 2015
    end

    it 'for 2016, it is 2015' do
      expect(described_class.new(2016).determine).to be 2015
    end

    it 'for 2017, it is 2015' do
      expect(described_class.new(2017).determine).to be 2015
    end

    it 'for 2018, it is 2015' do
      expect(described_class.new(2018).determine).to be 2015
    end

    it 'for 2019, it is 2015' do
      expect(described_class.new(2019).determine).to be 2015
    end

    it 'for 2020, it is 2020' do
      expect(described_class.new(2020).determine).to be 2020
    end

    it 'for 2021 and later, it is 2020' do
      expect(described_class.new(2021).determine).to be 2020
    end
  end

  it 'knows a views-path that can be prepended' do
    expect(subject.view_path.to_s).to match(%r!hitobito_insieme!) # in the wagon
    expect(subject.view_path.to_s).to match(%r!app/views/vertragsperioden/2020!) # a certain directory
  end

  it 'can load modules from namespace' do
    expect(subject.domain_module('TimeRecord::Table')).to be Vertragsperioden::Vp2020::TimeRecord::Table
  end
end
