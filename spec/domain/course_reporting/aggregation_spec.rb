# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CourseReporting::Aggregation do

  let(:values) do
    { kursdauer: 0.5,
      challenged_canton_count_attributes: { be: 1, zh: 2 },
      affiliated_canton_count_attributes: { be: 2 },
      teilnehmende_weitere: 4,
      absenzen_behinderte: 0.5,
      absenzen_angehoerige: 0,
      absenzen_weitere: nil,
      leiterinnen: 1,
      fachpersonen: 2,
      hilfspersonal_ohne_honorar: 3,
      hilfspersonal_mit_honorar: 4,
      kuechenpersonal: 5,
      honorare_inkl_sozialversicherung: 10,
      unterkunft: 20,
      uebriges: 30,
      beitraege_teilnehmende: 10,
      spezielle_unterkunft: true,
      gemeinkostenanteil: 10,
    }
  end

  let(:aggregation) { new_aggregation }

  before { Event::CourseRecord.destroy_all }

  context '#scope' do
    before { create!(create_course) }

    it 'returns records grouped by kursart and inputkriterien' do
      expect(aggregation.scope.count).to eq({ ['freizeit_und_sport', 'a'] => 1 })
    end

    it 'filters based on leistungskategorie' do
      aggregation = new_aggregation(leistungskategorie: :sk)
      expect(aggregation.scope.count).to be_empty
    end

    it 'filters based on group' do
      aggregation = new_aggregation(group_id: groups(:dachverein).id)
      expect(aggregation.scope.count).to be_empty
    end

    it 'filters based on year' do
      aggregation = new_aggregation(year: 2012)
      expect(aggregation.scope.count).to be_empty
    end

    it 'filters based on zugeteilte_kategorie' do
      aggregation = new_aggregation(zugeteilte_kategorie: [2])
      expect(aggregation.scope.count).to be_empty
    end

    it 'filters based on subventioniert' do
      aggregation = new_aggregation(subventioniert: false)
      expect(aggregation.scope.count).to be_empty
    end
  end

  context 'structure and counting courses' do
    let(:kriterien) { %w(a b) }

    it 'bk sums by inputkriterien' do
      kriterien.each { |k| create!(create_course, :freizeit_und_sport, inputkriterien: k) }

      expect(course_totals(:anzahl_kurse, 'a')).to eq(1)
      expect(course_totals(:anzahl_kurse, 'b')).to eq(1)
      expect(course_totals(:anzahl_kurse, 'c')).to eq(0)

      kriterien.each do |k|
        expect(course_counts(:anzahl_kurse, :freizeit_und_sport, k)).to eq(1)
        expect(course_counts(:anzahl_kurse, :weiterbildung, k)).to eq(nil)
      end
    end

    %w(sk tk).each do |leistungskategorie|
      context leistungskategorie do
        let(:aggregation) { new_aggregation(leistungskategorie: leistungskategorie) }

        it "sums once for all inputkriterien" do
          kriterien.each { |k| create!(create_course(leistungskategorie), 'freizeit_und_sport', inputkriterien: k) }

          expect(course_counts(:anzahl_kurse, 'freizeit_und_sport', 'all')).to eq(2)
          expect(course_totals(:anzahl_kurse)).to eq(2)
        end
      end
    end
  end

  context 'summed and aggregated values' do
    it "builds total and value for three 'freizeit_und_sport' records" do
      3.times { create!(create_course, 'freizeit_und_sport', values) }

      assert_summed_totals

      expect_values(:anzahl_kurse, 3)
      expect_values(:kursdauer, 1.5)

      expect_values(:teilnehmende, 27, 27, 0)
      expect_values(:teilnehmende_behinderte, 9)
      expect_values(:teilnehmende_angehoerige, 6)
      expect_values(:teilnehmende_weitere, 12)

      expect_values(:total_tage_teilnehmende, 12, 12, 0)
      expect_values(:tage_behinderte, 3, 3, 0)
      expect_values(:tage_angehoerige, 3, 3, 0)
      expect_values(:tage_weitere, 6, 6, 0)

      expect_values(:total_absenzen, 1.5, 1.5, 0)
      expect_values(:absenzen_behinderte, 1.5)
      expect_values(:absenzen_angehoerige, 0, 0, nil)
      expect_values(:absenzen_weitere, 0, nil, nil)

      expect_values(:betreuende, 30, 30, 0)
      expect_values(:leiterinnen, 3)
      expect_values(:fachpersonen, 6)
      expect_values(:hilfspersonal_ohne_honorar, 9)
      expect_values(:hilfspersonal_mit_honorar, 12)

      expect_values(:kuechenpersonal, 15)

      expect_values(:direkter_aufwand, 180, 180, 0)
      expect_values(:honorare_inkl_sozialversicherung, 30)
      expect_values(:unterkunft, 60)
      expect_values(:uebriges, 90)

      dk_pro_le = 180.to_d / 12.to_d # total_direkte_kosten / total_tage_teilnehmende
      vk_pro_le = 210.to_d / 12.to_d # total_vollkosten / total_tage_teilnehmende

      expect_values(:direkte_kosten_pro_le, dk_pro_le, dk_pro_le, 0)
      expect_values(:total_vollkosten, 210, 210, 0)
      expect_values(:vollkosten_pro_le, vk_pro_le, vk_pro_le, 0)
      expect_values(:total_direkte_kosten, 180)

      expect_values(:beitraege_teilnehmende, 30)
      expect_values(:gemeinkostenanteil, 30)
      expect_values(:betreuungsschluessel, 9/30.0, 9/30.0, 0)

      expect_values(:anzahl_spezielle_unterkunft, 3, 3, 0)
    end

    it "builds total and value for two 'freizeit_und_sport' and two 'weiterbildung' records" do
      2.times { create!(create_course, 'freizeit_und_sport', values) }
      2.times { create!(create_course, 'weiterbildung', values) }

      assert_summed_totals

      expect_values(:anzahl_kurse, 4, 2, 2)
      expect_values(:kursdauer, 2, 1, 1)

      expect_values(:teilnehmende, 36, 18, 18)
      expect_values(:teilnehmende_behinderte, 12, 6, 6)
      expect_values(:teilnehmende_angehoerige, 8, 4, 4)
      expect_values(:teilnehmende_weitere, 16, 8, 8)

      expect_values(:total_tage_teilnehmende, 16, 8, 8)
      expect_values(:tage_behinderte, 4, 2, 2)
      expect_values(:tage_angehoerige, 4, 2, 2)
      expect_values(:tage_weitere, 8, 4, 4)

      expect_values(:total_absenzen, 2, 1, 1)
      expect_values(:absenzen_behinderte, 2, 1, 1)
      expect_values(:absenzen_angehoerige, 0, 0, 0)
      expect_values(:absenzen_weitere, 0, nil, nil)

      expect_values(:betreuende, 40, 20, 20)
      expect_values(:leiterinnen, 4, 2, 2)
      expect_values(:fachpersonen, 8, 4, 4)
      expect_values(:hilfspersonal_ohne_honorar, 12, 6, 6)
      expect_values(:hilfspersonal_mit_honorar, 16, 8, 8)
      expect_values(:kuechenpersonal, 20, 10, 10)

      expect_values(:direkter_aufwand, 240, 120, 120)
      expect_values(:honorare_inkl_sozialversicherung, 40, 20, 20)
      expect_values(:unterkunft, 80, 40, 40)
      expect_values(:uebriges, 120, 60, 60)

      dk_pro_le = 240.to_d / 16 # total_direkte_kosten / total_tage_teilnehmende
      vk_pro_le = 280.to_d / 16 # total_vollkosten / total_tage_teilnehmende

      expect_values(:direkte_kosten_pro_le, dk_pro_le, dk_pro_le, dk_pro_le)
      expect_values(:vollkosten_pro_le, vk_pro_le, vk_pro_le, vk_pro_le)
      expect_values(:total_direkte_kosten, 240, 120, 120)

      expect_values(:beitraege_teilnehmende, 40, 20, 20)
      expect_values(:gemeinkostenanteil, 40, 20, 20)
      expect_values(:betreuungsschluessel, 12/40.0, 12/40.0, 12/40.0)

      expect_values(:anzahl_spezielle_unterkunft, 4, 2, 2)
    end

    it "sums 'spezielle_unterkunft' correctly" do
      create!(create_course, 'freizeit_und_sport', values.merge(spezielle_unterkunft: false))
      create!(create_course, 'weiterbildung', values.merge(spezielle_unterkunft: true))
      expect_values(:anzahl_spezielle_unterkunft, 1, 0, 1)
    end
  end

  def assert_summed_totals
    records = Event::CourseRecord.all.to_a
    attrs = CourseReporting::Aggregation::RUBY_SUMMED_ATTRS
    attrs.each do |attr|
      expected = records.sum { |r| r.send(attr).to_d }
      actual = course_totals(attr)
      expect(actual).to eq(expected), "expected #{attr} to equal #{expected}, got #{actual}"
    end
  end

  def course_counts(attr, kursart = :freizeit_und_sport, kriterium = :a)
    aggregation.course_counts(kriterium.to_s, kursart.to_s, attr)
  end

  def course_totals(attr, kriterium = :all)
    course_counts(attr, :total, kriterium)
  end

  def expect_values(attr, total, freizeit_und_sport = total, weiterbildung = nil)
    expect(course_totals(attr)).to eq(total), "expected #{attr} to equal #{total}, got #{course_totals(attr)}"
    expect(course_counts(attr, :freizeit_und_sport)).to eq(freizeit_und_sport)
    expect(course_counts(attr, :weiterbildung)).to eq(weiterbildung)
  end

  def new_aggregation(attrs = {})
    defaults = { group_id: groups(:be).id,
                 year: 2014,
                 leistungskategorie: 'bk',
                 zugeteilte_kategorie: [1],
                 subventioniert: true }
    described_class.new(*defaults.merge(attrs).values)
  end

  def create_course(leistungskategorie = 'bk', group_list = [groups(:be)], year = 2014)
    Event::Course.create!(groups: group_list,
                          name: 'test',
                          leistungskategorie: leistungskategorie,
                          dates_attributes: [{ start_at: DateTime.new(year, 04, 15, 12, 00) }])
  end

  def create!(event, kursart = 'freizeit_und_sport', attrs = {})
    Event::CourseRecord.create!(attrs.merge(event: event, kursart: kursart.to_s))
  end

end
