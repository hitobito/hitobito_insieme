# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::CourseRecord do

  let(:group) { groups(:be) }
  let(:event_bk) do
    Fabricate(:course, groups: [group], kind: Event::Kind.first,
              leistungskategorie: 'bk')
  end
  let(:event_tk) do
    Fabricate(:course, groups: [group], kind: Event::Kind.first,
              leistungskategorie: 'tk')
  end
  let(:event_sk) do
    Fabricate(:course, groups: [group], kind: Event::Kind.first,
              leistungskategorie: 'sk')
  end

  context 'validation' do
    it 'is fine with empty fields' do
      r = Event::CourseRecord.new(event: event_bk)
      r.should be_valid
    end

    it 'fails for inputkriterien other than \'a\', \'b\' or \'c\'' do
      r = Event::CourseRecord.new(event: event_bk, inputkriterien: 'a')
      r.should be_valid

      r = Event::CourseRecord.new(event: event_bk, inputkriterien: 'b')
      r.should be_valid

      r = Event::CourseRecord.new(event: event_bk, inputkriterien: 'c')
      r.should be_valid

      r = Event::CourseRecord.new(event: event_bk, inputkriterien: 'd')
      r.should_not be_valid

      r = Event::CourseRecord.new(event: event_bk)
      r.should be_valid
    end

    it 'fails for not subsidized event with inputkriterien not being \'a\'' do
      r = Event::CourseRecord.new(event: event_bk, inputkriterien: 'a', subventioniert: true)
      r.should be_valid

      r = Event::CourseRecord.new(event: event_bk, inputkriterien: 'b', subventioniert: true)
      r.should be_valid

      r = Event::CourseRecord.new(event: event_bk, inputkriterien: 'a', subventioniert: false)
      r.should be_valid

      r = Event::CourseRecord.new(event: event_bk, inputkriterien: 'b', subventioniert: false)
      r.should_not be_valid
    end

    it 'fails for semester-/jahreskurs with inputkriterien not being \'a\'' do
      event_sk = Fabricate(:course, groups: [group], kind: Event::Kind.first,
                           leistungskategorie: 'sk')

      r = Event::CourseRecord.new(event: event_bk, inputkriterien: 'a')
      r.should be_valid

      r = Event::CourseRecord.new(event: event_bk, inputkriterien: 'b')
      r.should be_valid

      r = Event::CourseRecord.new(event: event_sk, inputkriterien: 'a')
      r.should be_valid

      r = Event::CourseRecord.new(event: event_sk, inputkriterien: 'b')
      r.should_not be_valid
    end

    it 'fails for kursart other than \'weiterbildung\' or \'freizeit_und_sport\'' do
      r = Event::CourseRecord.new(event: event_bk, kursart: 'weiterbildung')
      r.should be_valid

      r = Event::CourseRecord.new(event: event_bk, kursart: 'freizeit_und_sport')
      r.should be_valid

      r = Event::CourseRecord.new(event: event_bk, kursart: 'freizeit_und_sport')
      r.should be_valid

      r = Event::CourseRecord.new(event: event_bk, kursart: 'foo')
      r.should_not be_valid

      r = Event::CourseRecord.new(event: event_bk)
      r.should be_valid
    end

    it 'is fine for decimal time values that are a multiple of 0.5 for bk/tk courses' do
      r = Event::CourseRecord.new(event: event_bk, kursdauer: 1.5, absenzen_behinderte: 1.5,
                                  absenzen_angehoerige: 1.5, absenzen_weitere: 1.5)
      r.should be_valid

      r = Event::CourseRecord.new(event: event_tk, kursdauer: 1.5, absenzen_behinderte: 1.5,
                                  absenzen_angehoerige: 1.5, absenzen_weitere: 1.5)
      r.should be_valid
    end

    it 'fails for decimal time values that are not a multiple of 0.5 for bk/tk courses' do
      r = Event::CourseRecord.new(event: event_bk, kursdauer: 1.25, absenzen_behinderte: 1.25,
                                  absenzen_angehoerige: 1.25, absenzen_weitere: 1.25)
      r.should_not be_valid
      r.errors.count.should eq(4)

      r = Event::CourseRecord.new(event: event_tk, kursdauer: 1.25, absenzen_behinderte: 1.25,
                                  absenzen_angehoerige: 1.25, absenzen_weitere: 1.25)
      r.should_not be_valid
      r.errors.count.should eq(4)
    end

    it 'is fine for integer time values for sk course' do
      r = Event::CourseRecord.new(event: event_sk, kursdauer: 1, absenzen_behinderte: 1,
                                  absenzen_angehoerige: 1, absenzen_weitere: 1)
      r.should be_valid
    end

    it 'is fine for integer time values for sk course' do
      r = Event::CourseRecord.new(event: event_sk, kursdauer: 1.5, absenzen_behinderte: 1.5,
                                  absenzen_angehoerige: 1.5, absenzen_weitere: 1.5)
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

  context 'default value' do
    it 'should be true for subventioniert' do
      r = Event::CourseRecord.new(event: event_bk)
      r.subventioniert.should be_true
    end

    it 'should be \'a\' for inputkriterien' do
      r = Event::CourseRecord.new(event: event_bk)
      r.inputkriterien.should eq('a')
    end

    it 'should be \'weiterbildung\' for kursart' do
      r = Event::CourseRecord.new(event: event_bk)
      r.kursart.should eq('weiterbildung')
    end

    it 'should be false for spezielle_unterkunft of sk course)' do
      r = Event::CourseRecord.new(event: event_bk, spezielle_unterkunft: true)
      r.spezielle_unterkunft.should be_true

      r = Event::CourseRecord.new(event: event_bk)
      r.spezielle_unterkunft.should be_false

      r = Event::CourseRecord.new(event: event_tk, spezielle_unterkunft: true)
      r.spezielle_unterkunft.should be_true

      r = Event::CourseRecord.new(event: event_tk)
      r.spezielle_unterkunft.should be_false

      r = Event::CourseRecord.new(event: event_sk, spezielle_unterkunft: true)
      r.spezielle_unterkunft.should be_false

      r = Event::CourseRecord.new(event: event_sk)
      r.spezielle_unterkunft.should be_false
    end
  end

  context 'leistungskategorie helpers' do
    it 'should reflect bk course' do
      r = Event::CourseRecord.new(event: event_bk)
      r.bk?.should be_true
      r.tk?.should be_false
      r.sk?.should be_false
      r.not_sk?.should be_true
    end

    it 'should reflect tk course' do
      r = Event::CourseRecord.new(event: event_tk)
      r.bk?.should be_false
      r.tk?.should be_true
      r.sk?.should be_false
      r.not_sk?.should be_true
    end

    it 'should reflect sk course' do
      r = Event::CourseRecord.new(event: event_sk)
      r.bk?.should be_false
      r.tk?.should be_false
      r.sk?.should be_true
      r.not_sk?.should be_false
    end
  end

end
