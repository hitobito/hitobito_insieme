# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::CourseRecord do

  let(:group) { groups(:be) }
  let(:event) { Fabricate(:course, groups: [group], kind: Event::Kind.first) }

  context 'validation' do
    it 'is fine with empty fields' do
      r = Event::CourseRecord.new(event: event, inputkriterien: 'a', kursart: 'weiterbildung')
      r.should be_valid
    end

    it 'fails for inputkriterien other than \'a\', \'b\' or \'c\' (default is \'a\')' do
      r = Event::CourseRecord.new(event: event, inputkriterien: 'a',
                                  subventioniert: true, kursart: 'weiterbildung')
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'b',
                                  subventioniert: true, kursart: 'weiterbildung')
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'c',
                                  subventioniert: true, kursart: 'weiterbildung')
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'd',
                                  subventioniert: true, kursart: 'weiterbildung')
      r.should_not be_valid

      r = Event::CourseRecord.new(event: event,
                                  subventioniert: true, kursart: 'weiterbildung')
      r.should be_valid
      r.inputkriterien.should eq('a')
    end

    it 'fails for not subsidized event with inputkriterien not being \'a\'' do
      r = Event::CourseRecord.new(event: event, inputkriterien: 'a', kursart: 'weiterbildung',
                                  subventioniert: true)
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'b', kursart: 'weiterbildung',
                                  subventioniert: true)
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'a', kursart: 'weiterbildung',
                                  subventioniert: false)
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'b', kursart: 'weiterbildung',
                                  subventioniert: false)
      r.should_not be_valid
    end

    # TODO: enable the following test if 'leistungskategorie' is available:
    xit 'fails for semester-/jahreskurs with inputkriterien not being \'a\'' do
      semester_jahreskurs = Fabricate(:course, groups: [group], kind: Event::Kind.first,
                                      leistungskategorie: 'semester_jahreskurs')

      r = Event::CourseRecord.new(event: event, inputkriterien: 'a', kursart: 'weiterbildung')
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'b', kursart: 'weiterbildung')
      r.should be_valid

      r = Event::CourseRecord.new(event: semester_jahreskurs, inputkriterien: 'a',
                                  kursart: 'weiterbildung')
      r.should be_valid

      r = Event::CourseRecord.new(event: semester_jahreskurs, inputkriterien: 'b',
                                  kursart: 'weiterbildung')
      r.should_not be_valid
    end

    it 'fails for kursart other than \'weiterbildung\' or \'freizeit_und_sport\' (no default)' do
      r = Event::CourseRecord.new(event: event, inputkriterien: 'a', kursart: 'weiterbildung')
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'a', kursart: 'freizeit_und_sport')
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'a', kursart: 'freizeit_und_sport')
      r.should be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'a', kursart: 'foo')
      r.should_not be_valid

      r = Event::CourseRecord.new(event: event, inputkriterien: 'a')
      r.should_not be_valid
    end

    it 'is fine for time values that are a multiple of 0.5' do
      r = Event::CourseRecord.new(event: event, inputkriterien: 'a', kursart: 'weiterbildung',
                                  kurstage: 1.5, absenzen_behinderte: 1.5,
                                  absenzen_angehoerige: 1.5, absenzen_weitere: 1.5)
      r.should be_valid
    end

    it 'fails for time values that are not a multiple of 0.5' do
      r = Event::CourseRecord.new(event: event, inputkriterien: 'a', kursart: 'weiterbildung',
                                  kurstage: 1.25, absenzen_behinderte: 1.25,
                                  absenzen_angehoerige: 1.25, absenzen_weitere: 1.25)
      r.should_not be_valid
      r.errors.count.should eq(4)
    end

    it 'fails for invalid event' do
      simple_event = Fabricate(:event, groups: [group])
      r = Event::CourseRecord.new(event: simple_event, inputkriterien: 'a',
                                  kursart: 'weiterbildung')
      r.should_not be_valid
      r.errors.count.should eq(1)
    end
  end

end
