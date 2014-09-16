# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::CourseRecord do

  let(:group) { groups(:be) }
  let(:event) do
    Fabricate(:course, groups: [group], kind: Event::Kind.first,
              leistungskategorie: 'bk')
  end

  context 'validation' do
    it 'is fine with empty fields' do
      r = Event::CourseRecord.new(event: event)
      r.should be_valid
    end

    it 'fails for inputkriterien other than \'a\', \'b\' or \'c\'' do
      r = Event::CourseRecord.new(event: event, inputkriterien: 'a')
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'b')
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'c')
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'd')
      r.should_not be_valid

      # fallback to default
      r = Event::CourseRecord.new(event: event)
      r.should be_valid
      r.inputkriterien.should eq('a')
    end

    it 'fails for not subsidized event with inputkriterien not being \'a\'' do
      r = Event::CourseRecord.new(event: event, inputkriterien: 'a', subventioniert: true)
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'b', subventioniert: true)
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'a', subventioniert: false)
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'b', subventioniert: false)
      r.should_not be_valid
    end

    it 'fails for semester-/jahreskurs with inputkriterien not being \'a\'' do
      event_sk = Fabricate(:course, groups: [group], kind: Event::Kind.first,
                           leistungskategorie: 'sk')

      r = Event::CourseRecord.new(event: event, inputkriterien: 'a')
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'b')
      r.should be_valid

      r = Event::CourseRecord.new(event: event_sk, inputkriterien: 'a')
      r.should be_valid

      r = Event::CourseRecord.new(event: event_sk, inputkriterien: 'b')
      r.should_not be_valid
    end

    it 'fails for kursart other than \'weiterbildung\' or \'freizeit_und_sport\'' do
      r = Event::CourseRecord.new(event: event, kursart: 'weiterbildung')
      r.should be_valid

      r = Event::CourseRecord.new(event: event, kursart: 'freizeit_und_sport')
      r.should be_valid

      r = Event::CourseRecord.new(event: event, kursart: 'freizeit_und_sport')
      r.should be_valid

      r = Event::CourseRecord.new(event: event, kursart: 'foo')
      r.should_not be_valid

      # fallback to default
      r = Event::CourseRecord.new(event: event)
      r.should be_valid
      r.kursart.should eq('weiterbildung')
    end

    it 'is fine for time values that are a multiple of 0.5' do
      r = Event::CourseRecord.new(event: event, kurstage: 1.5, absenzen_behinderte: 1.5,
                                  absenzen_angehoerige: 1.5, absenzen_weitere: 1.5)
      r.should be_valid
    end

    it 'fails for time values that are not a multiple of 0.5' do
      r = Event::CourseRecord.new(event: event, kurstage: 1.25, absenzen_behinderte: 1.25,
                                  absenzen_angehoerige: 1.25, absenzen_weitere: 1.25)
      r.should_not be_valid
      r.errors.count.should eq(4)
    end

    it 'fails for invalid event' do
      simple_event = Fabricate(:event, groups: [group])
      r = Event::CourseRecord.new(event: simple_event)
      r.should_not be_valid
      r.errors.count.should eq(1)
    end
  end

end
