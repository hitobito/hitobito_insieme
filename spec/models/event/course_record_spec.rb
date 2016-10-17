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
#  subventioniert                   :boolean          default(TRUE), not null
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
#  spezielle_unterkunft             :boolean          default(FALSE), not null
#  year                             :integer
#  teilnehmende_mehrfachbehinderte  :integer
#  direkter_aufwand                 :decimal(12, 2)
#  gemeinkostenanteil               :decimal(12, 2)
#  gemeinkosten_updated_at          :datetime
#  zugeteilte_kategorie             :string(2)
#  challenged_canton_count_id       :integer
#  affiliated_canton_count_id       :integer
#  anzahl_kurse                     :integer          default(1)
#  tage_behinderte                  :decimal(12, 2)
#  tage_angehoerige                 :decimal(12, 2)
#  tage_weitere                     :decimal(12, 2)
#

require 'spec_helper'

describe Event::CourseRecord do

  let(:group) { groups(:be) }

  let(:event_bk) { events(:top_course) }
  let(:event_tk) { Fabricate(:course, groups: [group], leistungskategorie: 'tk') }
  let(:event_sk) { Fabricate(:course, groups: [group], leistungskategorie: 'sk') }
  let(:aggregate_bk) do
    Fabricate(:aggregate_course, groups: [group], leistungskategorie: 'bk', year: 2000)
  end

  def new_record(event, attrs = {})
    event.course_record.try(:destroy!)
    r = Event::CourseRecord.new(attrs.merge(event: event))
    r.valid?
    r
  end

  context 'validation' do
    it 'is fine with empty fields' do
      expect(new_record(event_bk)).to be_valid
    end

    it 'fails for inputkriterien other than a, b or c' do
      expect(new_record(event_bk, inputkriterien: 'a')).to be_valid
      expect(new_record(event_bk, inputkriterien: 'b')).to be_valid
      expect(new_record(event_bk, inputkriterien: 'c')).to be_valid
      expect(new_record(event_bk, inputkriterien: 'd')).not_to be_valid
    end

    it 'all inputkriterien are valid for subventioniert or not' do
      expect(new_record(event_bk, inputkriterien: 'a', subventioniert: true)).to be_valid
      expect(new_record(event_bk, inputkriterien: 'b', subventioniert: true)).to be_valid
      expect(new_record(event_bk, inputkriterien: 'a', subventioniert: false)).to be_valid
      expect(new_record(event_bk, inputkriterien: 'b', subventioniert: false)).to be_valid
    end

    it 'sets inputkriterien to a for semester-/jahreskurs' do
      expect(new_record(event_sk, inputkriterien: 'b').inputkriterien).to eq 'a'
    end

    it 'fails for kursart other than weiterbildung or freizeit_und_sport' do
      expect(new_record(event_bk, kursart: 'weiterbildung')).to be_valid
      expect(new_record(event_bk, kursart: 'freizeit_und_sport')).to be_valid
      expect(new_record(event_bk, kursart: 'freizeit_und_sport')).to be_valid
      expect(new_record(event_bk, kursart: 'foo')).not_to be_valid
    end

    it 'is fine for decimal time values that are a multiple of 0.5 for bk/tk courses' do
      expect(new_record(event_bk,
        kursdauer: 1.5,
        challenged_canton_count_attributes: { ag: 2 },
        affiliated_canton_count_attributes: { ag: 1 },
        teilnehmende_weitere: 3,
        absenzen_behinderte: 1.5,
        absenzen_angehoerige: 1.5,
        absenzen_weitere: 1.5)).to be_valid

      expect(new_record(event_tk,
        kursdauer: 1.5,
        challenged_canton_count_attributes: { ag: 2 },
        affiliated_canton_count_attributes: { ag: 1 },
        teilnehmende_weitere: 3,
        absenzen_behinderte: 1.5,
        absenzen_angehoerige: 1.5,
        absenzen_weitere: 1.5)).to be_valid
    end

    it 'is fine for decimal time values that are a multiple of 0.5 for aggregate bk courses' do
      expect(new_record(aggregate_bk,
        kursdauer: 1.5,
        tage_behinderte: 4,
        tage_angehoerige: 2.5,
        tage_weitere: 0.5,
        absenzen_behinderte: 1.5,
        absenzen_angehoerige: 1.5,
        absenzen_weitere: 1.5)).to be_valid
    end

    it 'fails for decimal time values that are not a multiple of 0.5 for bk/tk courses' do
      expect(new_record(event_bk,
        kursdauer: 1.25,
        challenged_canton_count_attributes: { ag: 2 },
        affiliated_canton_count_attributes: { ag: 1 },
        teilnehmende_weitere: 3,
        absenzen_behinderte: 1.25,
        absenzen_angehoerige: 1.25,
        absenzen_weitere: 1.25)).to have(4).errors

      expect(new_record(event_bk,
        kursdauer: 1.25,
        challenged_canton_count_attributes: { ag: 2 },
        affiliated_canton_count_attributes: { ag: 1 },
        teilnehmende_weitere: 3,
        absenzen_behinderte: 1.25,
        absenzen_angehoerige: 1.25,
        absenzen_weitere: 1.25)).to have(4).errors
    end

    it 'fails for decimal time values that are not a multiple of 0.5 for aggregate bk courses' do
      expect(new_record(aggregate_bk,
        kursdauer: 1.5,
        tage_behinderte: 4.25,
        tage_angehoerige: 2.15,
        tage_weitere: 0.75,
        absenzen_behinderte: 1.5,
        absenzen_angehoerige: 1.5,
        absenzen_weitere: 1.5)).to have(3).errors
    end

    it 'only accepts integer time values for sk course' do
      expect(new_record(event_sk,
        kursdauer: 1,
        challenged_canton_count_attributes: { ag: 2 },
        affiliated_canton_count_attributes: { ag: 3 },
        teilnehmende_weitere: 3,
        absenzen_behinderte: 1.0,
        absenzen_angehoerige: 2,
        absenzen_weitere: 0.0)).to be_valid

      expect(new_record(event_sk,
        kursdauer: 1.5,
        challenged_canton_count_attributes: { ag: 2 },
        affiliated_canton_count_attributes: { ag: 1 },
        teilnehmende_weitere: 3,
        absenzen_behinderte: 1.5,
        absenzen_angehoerige: 1.5,
        absenzen_weitere: 1.5)).to have(4).errors
    end

    it 'does not throw error if event has no leistungskategorie (regression for #16047)' do
      event_bk.update(leistungskategorie: nil)
      expect(new_record(event_bk, inputkriterien: 'a', kursart: 'freizeit_und_sport')).to be_valid
      expect(new_record(event_bk, inputkriterien: 'c', kursart: 'freizeit_und_sport')).to be_valid
    end
  end

  context 'default values' do
    it 'subventioniert defaults to true' do
      expect(new_record(event_bk)).to be_subventioniert
    end

    it 'inputkriterien defaults to a' do
      expect(new_record(event_bk).inputkriterien).to eq('a')
    end

    it 'kursart defaults to weiterbildung' do
      expect(new_record(event_bk).kursart).to eq('weiterbildung')
    end

    it 'year defaults to first event date year' do
      expect(new_record(event_bk).year).to eq event_bk.years.first
    end
  end


  context 'spezielle_unterkunft' do
    it 'can be overriden for bk and tk course' do
      expect(new_record(event_bk)).not_to be_spezielle_unterkunft
      expect(new_record(event_bk, spezielle_unterkunft: true)).to be_spezielle_unterkunft

      expect(new_record(event_tk)).not_to be_spezielle_unterkunft
      expect(new_record(event_tk, spezielle_unterkunft: true)).to be_spezielle_unterkunft
    end

    it 'is always false for sk course' do
      expect(new_record(event_sk)).not_to be_spezielle_unterkunft
      expect(new_record(event_sk, spezielle_unterkunft: true)).not_to be_spezielle_unterkunft
    end
  end

  context 'leistungskategorie helpers' do
    it 'should reflect bk course' do
      r = Event::CourseRecord.new(event: event_bk)
      expect(r.bk?).to be_truthy
      expect(r.tk?).to be_falsey
      expect(r.sk?).to be_falsey
    end

    it 'should reflect tk course' do
      r = Event::CourseRecord.new(event: event_tk)
      expect(r.bk?).to be_falsey
      expect(r.tk?).to be_truthy
      expect(r.sk?).to be_falsey
    end

    it 'should reflect sk course' do
      r = Event::CourseRecord.new(event: event_sk)
      expect(r.bk?).to be_falsey
      expect(r.tk?).to be_falsey
      expect(r.sk?).to be_truthy
    end
  end

  context 'present record values' do
    let(:record) do
      new_record(event_bk,
                 kursdauer: 5,
                 teilnehmende_weitere: 1,
                 leiterinnen: 3,
                 fachpersonen: 1,
                 hilfspersonal_mit_honorar: 2,
                 absenzen_behinderte: 2,
                 absenzen_weitere: 1,
                 honorare_inkl_sozialversicherung: 200,
                 uebriges: 50,
                 gemeinkostenanteil: 50,
                 challenged_canton_count_attributes: { ag: 5 },
                 affiliated_canton_count_attributes: { ag: 4 })
    end

    subject { record }

    context '#praesenz_prozent' do
      it 'is correct' do
        expect(subject.praesenz_prozent).to eq(94)
      end

      it 'calculates as specified in example' do
        # 202000/252000*100=80.16%
        subject.update_attribute(:tage_behinderte, 202000.0 - 24.0)
        subject.update_attribute(:absenzen_behinderte, 50000.0 - 1.0)
        expect(subject.praesenz_prozent).to eq(80)
      end
    end

    context '#tage_behinderte' do
      it 'is correct' do
        expect(subject.tage_behinderte).to eq(23)
      end
    end

    context '#tage_angehoerige' do
      it 'is correct' do
        expect(subject.tage_angehoerige).to eq(20)
      end
    end

    context '#tage_weitere' do
      it 'is correct' do
        expect(subject.tage_weitere).to eq(4)
      end
    end

    context '#sum_total_tage_teilnehmende' do
      it 'is correct' do
        expect(subject.total_tage_teilnehmende).to eq(47)
      end
    end

    context '#betreuungsschluessel' do
      it 'is correct' do
        expect(subject.betreuungsschluessel).to eq(5.to_d/6.to_d)
      end
    end

    context '#direkter_aufwand' do
      it 'is correct' do
        expect(subject.direkter_aufwand).to eq(250.to_d)
      end
    end

    context '#total_vollkosten' do
      it 'is correct' do
        expect(subject.total_vollkosten).to eq(300.to_d)
      end
    end

    context '#vollkosten_pro_le' do
      it 'is correct' do
        expect(subject.vollkosten_pro_le).to be_within(0.001).of(6.383.to_d)
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
        expect(subject.praesenz_prozent).to eq(100)
      end
    end

    context '#tage_behinderte' do
      it 'is correct' do
        expect(subject.tage_behinderte).to eq(0)
      end
    end

    context '#tage_angehoerige' do
      it 'is correct' do
        expect(subject.tage_angehoerige).to eq(0)
      end
    end

    context '#tage_weitere' do
      it 'is correct' do
        expect(subject.tage_weitere).to eq(0)
      end
    end

    context '#total_tage_teilnehmende' do
      it 'is correct' do
        expect(subject.total_tage_teilnehmende).to eq(0)
      end
    end

    context '#betreuungsschluessel' do
      it 'is correct' do
        expect(subject.betreuungsschluessel).to eq(0.to_d)
      end
    end

    context '#direkter_aufwand' do
      it 'is correct' do
        expect(subject.direkter_aufwand).to eq(0.to_d)
      end
    end

    context '#total_vollkosten' do
      it 'is correct' do
        expect(subject.total_vollkosten).to eq(0.to_d)
      end
    end

    context '#vollkosten_pro_le' do
      it 'is correct' do
        expect(subject.vollkosten_pro_le).to eq(0.to_d)
      end
    end
  end

  context 'canton counts' do
    let(:record) do
      new_record(event_bk)
    end

    it 'should default sums to 0' do
      expect(record.teilnehmende_behinderte).to be_nil
      expect(record.teilnehmende_angehoerige).to be_nil
      expect(record.teilnehmende_weitere).to be_nil
    end

    it 'should be accessible through the associations' do
      expect(record.challenged_canton_count).to be_nil
      expect(record.affiliated_canton_count).to be_nil

      record.build_challenged_canton_count
      record.build_affiliated_canton_count

      expect(record.challenged_canton_count).not_to be_nil
      expect(record.affiliated_canton_count).not_to be_nil
    end

    context '#sum_canton_counts' do
      it 'should not fail if association is not present' do
        record.valid?
        expect(record.teilnehmende_behinderte).to be_nil
        expect(record.teilnehmende_angehoerige).to be_nil
      end

      it 'should set total' do
        record.build_challenged_canton_count
        record.build_affiliated_canton_count

        record.challenged_canton_count.be = 3
        record.challenged_canton_count.zh = 2
        record.affiliated_canton_count.fr = 2
        record.affiliated_canton_count.ne = 1

        record.valid?

        expect(record.teilnehmende_behinderte).to eq 5
        expect(record.teilnehmende_angehoerige).to eq 3
      end
    end
  end

end
