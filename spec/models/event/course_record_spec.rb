# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: event_course_records
#
#  id                               :integer          not null, primary key
#  event_id                         :integer          not null
#  inputkriterien                   :string(1)
#  subventioniert                   :boolean
#  kursart                          :string(255)
#  kursdauer                        :decimal(12, 2)
#  teilnehmende_behinderte          :integer
#  teilnehmende_angehoerige         :integer
#  teilnehmende_weitere             :integer
#  absenzen_behinderte              :decimal(12, 2)
#  absenzen_angehoerige             :decimal(12, 2)
#  absenzen_weitere                 :decimal(12, 2)
#  leiterinnen                      :integer
#  fachpersonen                     :integer
#  hilfspersonal_ohne_honorar       :integer
#  hilfspersonal_mit_honorar        :integer
#  kuechenpersonal                  :integer
#  honorare_inkl_sozialversicherung :decimal(12, 2)
#  unterkunft                       :decimal(12, 2)
#  uebriges                         :decimal(12, 2)
#  beitraege_teilnehmende           :decimal(12, 2)
#  spezielle_unterkunft             :boolean
#  year                             :integer
#  teilnehmende_mehrfachbehinderte  :integer
#  total_direkte_kosten             :decimal(12, 2)
#  gemeinkostenanteil               :decimal(12, 2)
#  gemeinkosten_updated_at          :datetime
#  zugeteilte_kategorie             :string(2)
#

require 'spec_helper'

describe Event::CourseRecord do

  let(:group) { groups(:be) }

  let(:event_bk) { events(:top_course) }
  let(:event_tk) { Fabricate(:course, groups: [group], leistungskategorie: 'tk') }
  let(:event_sk) { Fabricate(:course, groups: [group], leistungskategorie: 'sk') }

  def new_record(event, attrs = {})
    r = Event::CourseRecord.new(attrs.merge(event: event))
    r.valid?
    r
  end

  context 'validation' do
    it 'is fine with empty fields' do
      new_record(event_bk).should be_valid
    end

    it 'fails for inputkriterien other than a, b or c' do
      new_record(event_bk, inputkriterien: 'a').should be_valid
      new_record(event_bk, inputkriterien: 'b').should be_valid
      new_record(event_bk, inputkriterien: 'c').should be_valid
      new_record(event_bk, inputkriterien: 'd').should_not be_valid
    end

    it 'all inputkriterien are valid for subventioniert or not' do
      new_record(event_bk, inputkriterien: 'a', subventioniert: true).should be_valid
      new_record(event_bk, inputkriterien: 'b', subventioniert: true).should be_valid
      new_record(event_bk, inputkriterien: 'a', subventioniert: false).should be_valid
      new_record(event_bk, inputkriterien: 'b', subventioniert: false).should be_valid
    end

    it 'sets inputkriterien to a for semester-/jahreskurs' do
      new_record(event_sk, inputkriterien: 'b').inputkriterien.should eq 'a'
    end

    it 'fails for kursart other than weiterbildung or freizeit_und_sport' do
      new_record(event_bk, kursart: 'weiterbildung').should be_valid
      new_record(event_bk, kursart: 'freizeit_und_sport').should be_valid
      new_record(event_bk, kursart: 'freizeit_und_sport').should be_valid
      new_record(event_bk, kursart: 'foo').should_not be_valid
    end

    it 'is fine for decimal time values that are a multiple of 0.5 for bk/tk courses' do
      new_record(event_bk, kursdauer: 1.5, absenzen_behinderte: 1.5,
                 absenzen_angehoerige: 1.5, absenzen_weitere: 1.5).should be_valid

      new_record(event_tk, kursdauer: 1.5, absenzen_behinderte: 1.5,
                 absenzen_angehoerige: 1.5, absenzen_weitere: 1.5).should be_valid
    end

    it 'fails for decimal time values that are not a multiple of 0.5 for bk/tk courses' do
      new_record(event_bk, kursdauer: 1.25, absenzen_behinderte: 1.25, absenzen_angehoerige: 1.25,
                 absenzen_weitere: 1.25).should have(4).errors

      new_record(event_bk, kursdauer: 1.25, absenzen_behinderte: 1.25, absenzen_angehoerige: 1.25,
                 absenzen_weitere: 1.25).should have(4).errors
    end

    it 'only accepts integer time values for sk course' do
      new_record(event_sk, kursdauer: 1, absenzen_behinderte: 1,
                 absenzen_angehoerige: 1, absenzen_weitere: 1).should be_valid

      new_record(event_sk, kursdauer: 1.5, absenzen_behinderte: 1.5,
                 absenzen_angehoerige: 1.5, absenzen_weitere: 1.5).should have(4).errors
    end
  end

  context 'default values' do
    it 'subventioniert defaults to true' do
      new_record(event_bk).should be_subventioniert
    end

    it 'inputkriterien defaults to a' do
      new_record(event_bk).inputkriterien.should eq('a')
    end

    it 'kursart defaults to weiterbildung' do
      new_record(event_bk).kursart.should eq('weiterbildung')
    end

    it 'kursart defaults to weiterbildung' do
      new_record(event_bk).year.should eq event_bk.years.first
    end
  end


  context 'spezielle_unterkunft' do
    it 'can be overriden for bk and tk course' do
      new_record(event_bk).should_not be_spezielle_unterkunft
      new_record(event_bk, spezielle_unterkunft: true).should be_spezielle_unterkunft

      new_record(event_tk).should_not be_spezielle_unterkunft
      new_record(event_tk, spezielle_unterkunft: true).should be_spezielle_unterkunft
    end

    it 'is always false for sk course' do
      new_record(event_sk).should_not be_spezielle_unterkunft
      new_record(event_sk, spezielle_unterkunft: true).should_not be_spezielle_unterkunft
    end
  end

  context 'leistungskategorie helpers' do
    it 'should reflect bk course' do
      r = Event::CourseRecord.new(event: event_bk)
      r.bk?.should be_true
      r.tk?.should be_false
      r.sk?.should be_false
    end

    it 'should reflect tk course' do
      r = Event::CourseRecord.new(event: event_tk)
      r.bk?.should be_false
      r.tk?.should be_true
      r.sk?.should be_false
    end

    it 'should reflect sk course' do
      r = Event::CourseRecord.new(event: event_sk)
      r.bk?.should be_false
      r.tk?.should be_false
      r.sk?.should be_true
    end
  end

  context 'present record values' do
    let(:record) do
      new_record(event_bk,
                 kursdauer: 5,
                 teilnehmende_behinderte: 5,
                 teilnehmende_angehoerige: 4,
                 teilnehmende_weitere: 1,
                 leiterinnen: 3,
                 fachpersonen: 1,
                 hilfspersonal_mit_honorar: 2,
                 absenzen_behinderte: 2,
                 absenzen_weitere: 1,
                 honorare_inkl_sozialversicherung: 200,
                 uebriges: 50,
                 gemeinkostenanteil: 50)
    end

    subject { record }

    context '#praesenz_prozent' do
      it 'is correct' do
        subject.praesenz_prozent.should eq(94)
      end
    end

    context '#tage_behinderte' do
      it 'is correct' do
        subject.tage_behinderte.should eq(23)
      end
    end

    context '#tage_angehoerige' do
      it 'is correct' do
        subject.tage_angehoerige.should eq(20)
      end
    end

    context '#tage_weitere' do
      it 'is correct' do
        subject.tage_weitere.should eq(4)
      end
    end

    context '#total_tage_teilnehmende' do
      it 'is correct' do
        subject.total_tage_teilnehmende.should eq(47)
      end
    end

    context '#betreuungsschluessel' do
      it 'is correct' do
        subject.betreuungsschluessel.should eq(5.to_d/6.to_d)
      end
    end

    context '#direkter_aufwand' do
      it 'is correct' do
        subject.direkter_aufwand.should eq(250.to_d)
      end
    end

    context '#total_vollkosten' do
      it 'is correct' do
        subject.total_vollkosten.should eq(300.to_d)
      end
    end

    context '#vollkosten_pro_le' do
      it 'is correct' do
        subject.vollkosten_pro_le.should be_within(0.001).of(6.383.to_d)
      end
    end
  end

  context 'blank record values' do
    let(:record) do
      new_record(event_bk)
    end

    subject { record }

    context '#praesenz_prozent' do
      it 'is correct' do
        subject.praesenz_prozent.should eq(100)
      end
    end

    context '#tage_behinderte' do
      it 'is correct' do
        subject.tage_behinderte.should eq(0)
      end
    end

    context '#tage_angehoerige' do
      it 'is correct' do
        subject.tage_angehoerige.should eq(0)
      end
    end

    context '#tage_weitere' do
      it 'is correct' do
        subject.tage_weitere.should eq(0)
      end
    end

    context '#total_tage_teilnehmende' do
      it 'is correct' do
        subject.total_tage_teilnehmende.should eq(0)
      end
    end

    context '#betreuungsschluessel' do
      it 'is correct' do
        subject.betreuungsschluessel.should eq(0.to_d)
      end
    end

    context '#direkter_aufwand' do
      it 'is correct' do
        subject.direkter_aufwand.should eq(0.to_d)
      end
    end

    context '#total_vollkosten' do
      it 'is correct' do
        subject.total_vollkosten.should eq(0.to_d)
      end
    end

    context '#vollkosten_pro_le' do
      it 'is correct' do
        subject.vollkosten_pro_le.should eq(0.to_d)
      end
    end

  end

  context 'canton counts' do
    let(:record) do
      new_record(event_bk)
    end

    it 'should default sums to 0' do
      record.teilnehmende_behinderte.should eq 0
      record.teilnehmende_angehoerige.should eq 0
    end

    it 'should be accessible through the associations' do
      record.challenged_canton_count.should be_nil
      record.affiliated_canton_count.should be_nil

      record.build_challenged_canton_count
      record.build_affiliated_canton_count

      record.challenged_canton_count.should_not be_nil
      record.affiliated_canton_count.should_not be_nil
    end

    context '#sum_canton_counts' do
      it 'should not fail if association is not present' do
        record.sum_canton_counts
        record.teilnehmende_behinderte.should eq 0
        record.teilnehmende_angehoerige.should eq 0
      end

      it 'should set total' do
        record.build_challenged_canton_count
        record.build_affiliated_canton_count

        record.challenged_canton_count.be = 3
        record.challenged_canton_count.zh = 2
        record.affiliated_canton_count.fr = 2
        record.affiliated_canton_count.ne = 1

        record.sum_canton_counts

        record.teilnehmende_behinderte.should eq 5
        record.teilnehmende_angehoerige.should eq 3
      end
    end
  end

end
