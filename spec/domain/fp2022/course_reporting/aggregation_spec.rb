#  Copyright (c) 2022-2021, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Fp2022::CourseReporting::Aggregation do
  include Featureperioden::Domain

  let(:year) { 2022 }
  let(:values) do
    {
      kursdauer: 0.5,
      challenged_canton_count_attributes: {be: 1, zh: 2},
      affiliated_canton_count_attributes: {be: 2},
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
      gemeinkostenanteil: 10
    }
  end

  let(:aggregation) { new_aggregation }

  before { Event::CourseRecord.destroy_all }

  context "#scope" do
    before { create!(create_course) }

    it "returns records grouped by kursart and kursfachkonzept" do
      expect(aggregation.scope.count).to eq({["freizeit_und_sport", "sport_jugend"] => 1})
    end

    it "filters based on leistungskategorie" do
      aggregation = new_aggregation(leistungskategorie: :sk)
      expect(aggregation.scope.count).to be_empty
    end

    it "filters based on group" do
      aggregation = new_aggregation(group_id: groups(:dachverein).id)
      expect(aggregation.scope.count).to be_empty
    end

    it "filters based on year" do
      aggregation = new_aggregation(year: 2012)
      expect(aggregation.scope.count).to be_empty
    end

    it "does not filter based on zugeteilte_kategorie anymore" do # see Fp2015, if you need this
      aggregation = new_aggregation(zugeteilte_kategorie: [2])
      expect(aggregation.scope.count).to_not be_empty
    end

    it "filters based on subventioniert" do
      aggregation = new_aggregation(subventioniert: false)
      expect(aggregation.scope.count).to be_empty
    end
  end

  context "structure and counting courses" do
    let(:kursfachkonzepte) { %w[freizeit_jugend autonomie_foerderung] }

    %w[bk tk].each do |leistungskategorie|
      context leistungskategorie do
        let(:aggregation) { new_aggregation(leistungskategorie: leistungskategorie) }

        it "sums by inputkritierien" do
          kursfachkonzepte.each do |k|
            create!(create_course(leistungskategorie, [groups(:be)], 2022, k), :freizeit_und_sport)
          end

          expect(course_totals(:anzahl_kurse, "freizeit_jugend")).to eq(1)
          expect(course_totals(:anzahl_kurse, "freizeit_erwachsen")).to eq(0)
          expect(course_totals(:anzahl_kurse, "sport_jugend")).to eq(0)
          expect(course_totals(:anzahl_kurse, "sport_erwachsen")).to eq(0)
          expect(course_totals(:anzahl_kurse, "autonomie_foerderung")).to eq(1)
        end
      end
    end

    context "sk" do
      let(:aggregation) { new_aggregation(leistungskategorie: "sk") }

      it "sums once for all kursfachkonzepte" do
        kursfachkonzepte.each do |k|
          create!(create_course("sk", [groups(:be)], 2022, k), "freizeit_und_sport")
        end

        expect(course_totals(:anzahl_kurse)).to eq(2)
      end
    end
  end

  context "summed and aggregated values" do
    it "builds total for three 'freizeit_und_sport' records" do
      3.times { create!(create_course, "freizeit_und_sport", values) }

      assert_summed_totals

      expect_values(:anzahl_kurse, 3)
      expect_values(:kursdauer, 1.5)

      expect_values(:teilnehmende, 27)
      expect_values(:teilnehmende_behinderte, 9)
      expect_values(:teilnehmende_angehoerige, 6)
      expect_values(:teilnehmende_weitere, 12)

      expect_values(:total_tage_teilnehmende, 12)
      expect_values(:tage_behinderte, 3)
      expect_values(:tage_angehoerige, 3)
      expect_values(:tage_weitere, 6)

      expect_values(:total_absenzen, 1.5)
      expect_values(:absenzen_behinderte, 1.5)
      expect_values(:absenzen_angehoerige, 0)
      expect_values(:absenzen_weitere, 0)

      expect_values(:betreuende, 30)
      expect_values(:leiterinnen, 3)
      expect_values(:fachpersonen, 6)
      expect_values(:betreuerinnen, 0)
      expect_values(:hilfspersonal_ohne_honorar, 9)
      expect_values(:hilfspersonal_mit_honorar, 12)

      expect_values(:kuechenpersonal, 15)

      expect_values(:direkter_aufwand, 180)
      expect_values(:honorare_inkl_sozialversicherung, 30)
      expect_values(:unterkunft, 60)
      expect_values(:uebriges, 90)

      dk_pro_le = BigDecimal("180") / BigDecimal("12") # direkter_aufwand / total_tage_teilnehmende
      vk_pro_le = BigDecimal("210") / BigDecimal("12") # total_vollkosten / total_tage_teilnehmende

      expect_values(:direkte_kosten_pro_le, dk_pro_le)
      expect_values(:total_vollkosten, 210)
      expect_values(:vollkosten_pro_le, vk_pro_le)
      expect_values(:direkter_aufwand, 180)

      expect_values(:beitraege_teilnehmende, 30)
      expect_values(:gemeinkostenanteil, 30)
      expect_values(:betreuungsschluessel, 9 / 30.0)

      expect_values(:anzahl_spezielle_unterkunft, 3)
    end

    it "builds total for two 'freizeit_und_sport' and two 'weiterbildung' records" do
      2.times { create!(create_course, "freizeit_und_sport", values) }
      2.times { create!(create_course, "weiterbildung", values) }

      assert_summed_totals

      expect_values(:anzahl_kurse, 4)
      expect_values(:kursdauer, 2)

      expect_values(:teilnehmende, 36)
      expect_values(:teilnehmende_behinderte, 12)
      expect_values(:teilnehmende_angehoerige, 8)
      expect_values(:teilnehmende_weitere, 16)

      expect_values(:total_tage_teilnehmende, 16)
      expect_values(:tage_behinderte, 4)
      expect_values(:tage_angehoerige, 4)
      expect_values(:tage_weitere, 8)

      expect_values(:total_absenzen, 2)
      expect_values(:absenzen_behinderte, 2)
      expect_values(:absenzen_angehoerige, 0)
      expect_values(:absenzen_weitere, 0)

      expect_values(:betreuende, 40)
      expect_values(:leiterinnen, 4)
      expect_values(:fachpersonen, 8)
      expect_values(:betreuerinnen, 0)
      expect_values(:hilfspersonal_ohne_honorar, 12)
      expect_values(:hilfspersonal_mit_honorar, 16)
      expect_values(:kuechenpersonal, 20)

      expect_values(:direkter_aufwand, 240)
      expect_values(:honorare_inkl_sozialversicherung, 40)
      expect_values(:unterkunft, 80)
      expect_values(:uebriges, 120)

      dk_pro_le = BigDecimal("240") / 16 # direkter_aufwand / total_tage_teilnehmende
      vk_pro_le = BigDecimal("280") / 16 # total_vollkosten / total_tage_teilnehmende

      expect_values(:direkte_kosten_pro_le, dk_pro_le)
      expect_values(:vollkosten_pro_le, vk_pro_le)
      expect_values(:direkter_aufwand, 240)

      expect_values(:beitraege_teilnehmende, 40)
      expect_values(:gemeinkostenanteil, 40)
      expect_values(:betreuungsschluessel, 12 / 40.0)

      expect_values(:anzahl_spezielle_unterkunft, 4)
    end

    it "sums 'spezielle_unterkunft' correctly" do
      create!(create_course, "freizeit_und_sport", values.merge(spezielle_unterkunft: false))
      create!(create_course, "weiterbildung", values.merge(spezielle_unterkunft: true))
      expect_values(:anzahl_spezielle_unterkunft, 1)
    end
  end

  context "over all groups" do
    let(:aggregation) { new_aggregation(group_id: nil) }

    it "sums the individual group aggregations" do
      2.times { create!(create_course, "freizeit_und_sport", values) }
      2.times { create!(create_course, "weiterbildung", values) }
      2.times { create!(create_course("bk", [groups(:fr)]), "weiterbildung", values) }

      assert_summed_totals

      aggregation_be_1 = new_aggregation
      aggregation_fr_1 = new_aggregation(group_id: groups(:fr).id)
      aggregation_be_123 = new_aggregation(zugeteilte_kategorie: [1, 2, 3])
      aggregation_fr_123 = new_aggregation(group_id: groups(:fr).id, zugeteilte_kategorie: [1, 2, 3])
      aggregation_123 = new_aggregation(group_id: nil, zugeteilte_kategorie: [1, 2, 3])

      [
        :anzahl_kurse,
        :kursdauer,

        :teilnehmende,
        :teilnehmende_behinderte,
        :teilnehmende_angehoerige,
        :teilnehmende_weitere,

        :total_absenzen,
        :absenzen_behinderte,
        :absenzen_angehoerige,
        :absenzen_weitere,

        :total_tage_teilnehmende,
        :tage_behinderte,
        :tage_angehoerige,
        :tage_weitere,

        :total_absenzen,
        :absenzen_behinderte,
        :absenzen_angehoerige,
        :absenzen_weitere,

        :betreuende,
        :leiterinnen,
        :fachpersonen,
        :hilfspersonal_ohne_honorar,
        :hilfspersonal_mit_honorar,
        :kuechenpersonal,

        :direkter_aufwand,
        :honorare_inkl_sozialversicherung,
        :unterkunft,
        :uebriges,

        :direkter_aufwand,

        :beitraege_teilnehmende,
        :gemeinkostenanteil,
        :anzahl_spezielle_unterkunft
      ].each do |attr|
        assert_summed(attr, :total, :all, aggregation, aggregation_be_1, aggregation_fr_1)
        assert_summed(attr, :total, :sport_jugend, aggregation, aggregation_be_1, aggregation_fr_1)

        assert_summed(attr, :total, :all, aggregation_123, aggregation_be_123, aggregation_fr_123)
        assert_summed(attr, :total, :sport_jugend, aggregation_123, aggregation_be_123, aggregation_fr_123)
      end

      dk_pro_le = BigDecimal("360") / 24 # direkter_aufwand / total_tage_teilnehmende
      vk_pro_le = BigDecimal("420") / 24 # total_vollkosten / total_tage_teilnehmende

      expect_values(:direkte_kosten_pro_le, dk_pro_le)
      expect_values(:vollkosten_pro_le, vk_pro_le)
      expect_values(:betreuungsschluessel, 18 / 60.0)
    end

    def assert_summed(attr, kursart, kursfachkonzept, overall, *aggregations)
      sum = aggregations.sum { |a| a.course_counts(kursfachkonzept.to_s, kursart.to_s, attr).to_d }
      actual = overall.course_counts(kursfachkonzept.to_s, kursart.to_s, attr).to_d
      expect(actual).to eq(sum)
    end
  end

  context "treffpunkt-aggregation" do
    let(:cr_defaults) do
      {
        subventioniert: true,
        year: year
      }
    end

    let!(:treffpunkt_a_course_record) do
      create!(create_course("tp", [groups(:fr)], 2022, "treffpunkt"), "weiterbildung", cr_defaults.merge({
        challenged_canton_count_attributes: {be: 10},
        affiliated_canton_count_attributes: {be: 2},

        kursdauer: 0.1e2,
        anzahl_kurse: 1,
        tage_behinderte: 0.1e3,
        tage_angehoerige: 0.0,
        tage_weitere: 0.0,
        betreuerinnen: 2
      }))
    end

    let!(:treffpunkt_b_course_record) do
      create!(create_course("tp", [groups(:fr)], 2022, "treffpunkt"), "weiterbildung", cr_defaults.merge({
        challenged_canton_count_attributes: {be: 5},
        affiliated_canton_count_attributes: {be: 1},

        kursdauer: 0.2e1,
        anzahl_kurse: 1,
        tage_behinderte: 0.1e2,
        tage_angehoerige: 0.0,
        tage_weitere: 0.0,
        betreuerinnen: 1
      }))
    end

    subject(:tp_agg) do
      described_class
        .new(groups(:fr).id, cr_defaults[:year], "tp", :unused, cr_defaults[:subventioniert])
        .course_counts("all", "total", :itself)
    end

    it "has assumptions" do
      expect(tp_agg).to be_a Event::CourseRecord
      expect(tp_agg).to be_aggregation_record

      expect(treffpunkt_a_course_record.teilnehmende_behinderte).to eq 10
      expect(treffpunkt_b_course_record.teilnehmende_behinderte).to eq 5
      expect(treffpunkt_a_course_record.teilnehmende_angehoerige).to eq 2

      expect(treffpunkt_a_course_record.betreuerinnen).to eq 2
      expect(treffpunkt_a_course_record.kursdauer).to eq 10
      expect(treffpunkt_a_course_record.betreuungsstunden).to eq(2 * 10) # 20

      expect(treffpunkt_b_course_record.betreuerinnen).to eq 1
      expect(treffpunkt_b_course_record.kursdauer).to eq 2
      expect(treffpunkt_b_course_record.betreuungsstunden).to eq(1 * 2) # 2
    end

    it "sums products and caluclated values correctly" do
      expect(tp_agg.anzahl_kurse).to eq 2
      expect(tp_agg.kursdauer).to eq 12
      expect(tp_agg.betreuungsstunden).to eq 22 # 20 + 2 -> see assumptions
      expect(tp_agg.total_stunden_betreuung).to eq 22 # same as betreuungsstunden (now)
      expect(tp_agg.betreuende).to eq 3
    end

    it "calculate the teilnehmer correctly" do
      expect(tp_agg.teilnehmende_behinderte).to eq 15 # 10 + 5 -> see assumptions
      expect(tp_agg.teilnehmende_angehoerige).to eq 3
      expect(tp_agg.teilnehmende_weitere).to eq 0
      expect(tp_agg.teilnehmende).to eq 18
    end
  end

  def assert_summed_totals
    records = Event::CourseRecord.all.to_a
    attrs = fp_class("CourseReporting::Aggregation")::RUBY_SUMMED_ATTRS
    attrs.each do |attr|
      expected = records.sum { |r| r.send(attr).to_d }
      actual = course_totals(attr)
      expect(actual).to eq(expected), "expected #{attr} to equal #{expected}, got #{actual}"
    end
  end

  def course_counts(attr, kursart = :freizeit_und_sport, kursfachkonzept = :sport_jugend)
    aggregation.course_counts(kursfachkonzept.to_s, kursart.to_s, attr)
  end

  def course_totals(attr, kursfachkonzept = :all)
    course_counts(attr, :total, kursfachkonzept)
  end

  def expect_values(attr, total)
    expect(course_totals(attr)).to eq(total), "expected #{attr} to equal #{total}, got #{course_totals(attr)}"
  end

  def new_aggregation(attrs = {})
    defaults = {group_id: groups(:be).id,
                year: 2022,
                leistungskategorie: "bk",
                zugeteilte_kategorie: [1],
                subventioniert: true}
    described_class.new(*defaults.merge(attrs).values)
  end

  def create_course(leistungskategorie = "bk", group_list = [groups(:be)], year = 2022, fachkonzept = "sport_jugend")
    Event::Course.create!(groups: group_list,
      name: "test",
      leistungskategorie: leistungskategorie, fachkonzept: fachkonzept,
      dates_attributes: [{start_at: DateTime.new(year, 0o4, 15, 12, 0o0)}])
  end

  def create!(event, kursart = "freizeit_und_sport", attrs = {})
    Event::CourseRecord.create!(attrs.merge(event: event, kursart: kursart.to_s))
  end
end
