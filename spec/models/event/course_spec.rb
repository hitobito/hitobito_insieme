# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Event::Course do

  subject do
    Fabricate(:course, groups: [groups(:dachverein)], leistungskategorie: 'bk')
  end

  context '#years' do
    context 'within same year' do
      before do
        subject.dates.destroy_all
        subject.dates.create!(start_at: Time.zone.parse('2014-10-01'),
                              finish_at: Time.zone.parse('2014-10-03'))
        subject.dates.create!(start_at: Time.zone.parse('2014-11-01'),
                              finish_at: Time.zone.parse('2014-11-03'))
      end

      its(:years) { should eq [2014] }
    end

    context 'multiple years' do
      before do
        subject.dates.destroy_all
        subject.dates.create!(start_at: Time.zone.parse('2013-09-01'),
                              finish_at: Time.zone.parse('2013-09-03'))
        subject.dates.create!(start_at: Time.zone.parse('2014-10-01'),
                              finish_at: Time.zone.parse('2014-10-03'))
        subject.dates.create!(start_at: Time.zone.parse('2014-12-01'),
                              finish_at: Time.zone.parse('2015-01-03'))
        subject.dates.create!(start_at: Time.zone.parse('2015-02-01'),
                              finish_at: Time.zone.parse('2015-02-03'))
      end

      its(:years) { should eq [2013, 2014, 2015] }
    end
  end

  context 'leistungskategorien' do
    let(:course) do
      Fabricate(:course, groups: [groups(:dachverein)], leistungskategorie: leistungskategorie)
    end

    context "contains Blockkurse" do
      let(:leistungskategorie) { 'bk' }

      it 'and is valid' do
        expect(course).to be_valid
      end
    end

    context "contains Tageskurse" do
      let(:leistungskategorie) { 'tk' }

      it 'and is valid' do
        expect(course).to be_valid
      end
    end

    context "contains Semesterkurse" do
      let(:leistungskategorie) { 'sk' }

      it 'and is valid' do
        expect(course).to be_valid
      end
    end

    context "contains Treffpunkte" do
      let(:leistungskategorie) { 'tp' }

      it 'and is valid' do
        expect(course).to be_valid
      end
    end
  end

  context '#available_leistungskategorien' do
    it 'translates Blockkurs' do
      expect(described_class.available_leistungskategorien).to include(['bk', 'Blockkurs'])
    end

    it 'translates Tageskurs' do
      expect(described_class.available_leistungskategorien).to include(['tk', 'Tageskurs'])
    end

    it 'translates Semesterkurs' do
      expect(described_class.available_leistungskategorien).to include(['sk', 'Semester-/Jahreskurs'])
    end

    it 'translates Treffpunkt' do
      expect(described_class.available_leistungskategorien).to include(['tp', 'Treffpunkt'])
    end
  end

end
