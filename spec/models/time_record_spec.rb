# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

# == Schema Information
#
# Table name: time_records
#
#  id                                       :integer          not null, primary key
#  group_id                                 :integer          not null
#  year                                     :integer          not null
#  verwaltung                               :integer
#  beratung                                 :integer
#  treffpunkte                              :integer
#  blockkurse                               :integer
#  tageskurse                               :integer
#  jahreskurse                              :integer
#  kontakte_medien                          :integer
#  interviews                               :integer
#  publikationen                            :integer
#  referate                                 :integer
#  medienkonferenzen                        :integer
#  informationsveranstaltungen              :integer
#  sensibilisierungskampagnen               :integer
#  auskunftserteilung                       :integer
#  kontakte_meinungsbildner                 :integer
#  beratung_medien                          :integer
#  eigene_zeitschriften                     :integer
#  newsletter                               :integer
#  informationsbroschueren                  :integer
#  eigene_webseite                          :integer
#  erarbeitung_instrumente                  :integer
#  erarbeitung_grundlagen                   :integer
#  projekte                                 :integer
#  vernehmlassungen                         :integer
#  gremien                                  :integer
#  vermittlung_kontakte                     :integer
#  unterstuetzung_selbsthilfeorganisationen :integer
#  koordination_selbsthilfe                 :integer
#  treffen_meinungsaustausch                :integer
#  beratung_fachhilfeorganisationen         :integer
#  unterstuetzung_behindertenhilfe          :integer
#  mittelbeschaffung                        :integer
#  allgemeine_auskunftserteilung            :integer
#  type                                     :string(255)      not null
#  total_lufeb_general                      :integer
#  total_lufeb_private                      :integer
#  total_lufeb_specific                     :integer
#  total_lufeb_promoting                    :integer
#  nicht_art_74_leistungen                  :integer
#

require "spec_helper"

describe TimeRecord do
  let(:record) do
    TimeRecord.new(group: groups(:be), year: 2014,
      total_lufeb_general: 1,
      total_lufeb_private: 2,
      total_lufeb_specific: 3,
      total_lufeb_promoting: 4,
      blockkurse: 5,
      tageskurse: 6,
      jahreskurse: 7,
      treffpunkte: 8,
      beratung: 9,
      mittelbeschaffung: 10,
      verwaltung: 11,
      nicht_art_74_leistungen: 12,

      # lufeb general
      kontakte_medien: 10,
      interviews: 11,
      publikationen: 12,
      referate: 13,
      medienkonferenzen: 14,
      informationsveranstaltungen: 15,
      sensibilisierungskampagnen: 16,
      allgemeine_auskunftserteilung: 17,
      kontakte_meinungsbildner: 18,
      beratung_medien: 19,

      # lufeb_private
      eigene_zeitschriften: 21,
      newsletter: 22,
      informationsbroschueren: 23,
      eigene_webseite: 24,

      # lufeb_specific
      erarbeitung_instrumente: 31,
      erarbeitung_grundlagen: 32,
      projekte: 33,
      vernehmlassungen: 34,
      gremien: 35,

      # lufeb_promoting
      auskunftserteilung: 41,
      vermittlung_kontakte: 42,
      unterstuetzung_selbsthilfeorganisationen: 43,
      koordination_selbsthilfe: 44,
      treffen_meinungsaustausch: 45,
      beratung_fachhilfeorganisationen: 46,
      unterstuetzung_behindertenhilfe: 47)
  end

  context "calculated totals" do
    context "#total_lufeb" do
      it "is 0 for new record" do
        expect(TimeRecord.new(year: 2024).total_lufeb).to eq(0)
      end

      it "is the sum the values set" do
        expect(record.total_lufeb).to eq 10
      end
    end

    context "#total_courses" do
      it "is 0 for new record" do
        expect(TimeRecord.new(year: 2024).total_courses).to eq(0)
      end

      it "is the sum the values set" do
        expect(record.total_courses).to eq 18
      end
    end

    context "#total_additional_person_specific" do
      it "is 0 for new record" do
        expect(TimeRecord.new(year: 2024).total_additional_person_specific).to eq(0)
      end

      it "is the sum the values set" do
        expect(record.total_additional_person_specific).to eq 17
      end
    end

    context "#total_remaining" do
      it "is 0 for new record" do
        expect(TimeRecord.new(year: 2024).total_remaining).to eq(0)
      end

      it "is the sum the values set" do
        expect(record.total_remaining).to eq 21
      end
    end

    context "#total_paragraph_74" do
      it "is 0 for new record" do
        expect(TimeRecord.new(year: 2024).total_paragraph_74).to eq(0)
      end

      it "is the sum the values set" do
        expect(record.total_paragraph_74).to eq 66
      end
    end

    context "#total_not_paragraph_74" do
      it "is 0 for new record" do
        expect(TimeRecord.new(year: 2024).total_not_paragraph_74).to eq(0)
      end

      it "is the sum the values set" do
        expect(record.total_not_paragraph_74).to eq 12
      end
    end
  end

  context "stored totals" do
    context "#update_totals" do
      it "is called on save" do
        expect(record).to receive(:update_totals)

        record.type = "TimeRecord::EmployeeTime"
        record.save!
      end
    end

    [[:total_lufeb_general, 145],
      [:total_lufeb_private, 90],
      [:total_lufeb_specific, 165],
      [:total_lufeb_promoting, 308],
      [:total, 776]].each do |method, value|
      context "##{method}" do
        if method == :total
          it "is 0 for new record before save" do
            expect(TimeRecord.new.send(method)).to eq 0
          end
        else
          it "is nil for new record before save" do
            expect(TimeRecord.new.send(method)).to be_nil
          end
        end

        it "is 0 for new record after save" do
          new_record = TimeRecord.new(group: groups(:be), year: 2014, type: "TimeRecord::EmployeeTime")
          new_record.save!
          expect(new_record.send(method)).to eq(0)
        end

        it "is the correct sum for nonempty record" do
          record.type = "TimeRecord::EmployeeTime"
          record.save!
          expect(record.send(method)).to eq(value)
        end
      end
    end
  end

  context "pensums" do
    it "exists a bsv_hours_per_year reporting parameter" do
      expect(ReportingParameter.for(2014).bsv_hours_per_year).to eq 1900
    end

    context "#total_paragraph_74_pensum" do
      it "is 0 for new record" do
        expect(TimeRecord.new(year: 2014).total_paragraph_74_pensum).to eq(0)
      end

      it "is the equivalent to 100%-jobs" do
        expect(record.total_paragraph_74_pensum).to eq BigDecimal(66) / 1900
      end
    end

    context "#total_not_paragraph_74_pensum" do
      it "is 0 for new record" do
        expect(TimeRecord.new(year: 2014).total_not_paragraph_74_pensum).to eq(0)
      end

      it "is the equivalent to 100%-jobs" do
        expect(record.total_not_paragraph_74_pensum).to eq BigDecimal(12) / 1900
      end
    end

    context "#total_pensum" do
      it "is 0 for new record before save" do
        expect(TimeRecord.new(year: 2014).total_pensum).to eq(0)
      end

      it "is 0 for new record after save" do
        new_record = TimeRecord.new(group: groups(:be), year: 2014, type: "TimeRecord::EmployeeTime")
        new_record.save!
        expect(new_record.total_pensum).to eq(0)
      end

      it "is the equivalent to 100%-jobs" do
        record.type = "TimeRecord::EmployeeTime"
        record.save!
        expect(record.total_pensum).to eq BigDecimal(776) / 1900
      end
    end
  end

  context "frozen reporting year" do
    before { GlobalValue.first.update!(reporting_frozen_until_year: 2015) }
    after { GlobalValue.clear_cache }

    it "cannot create new record" do
      record = TimeRecord.new(group: groups(:be), year: 2014, type: "TimeRecord::EmployeeTime")
      expect(record).to have(1).error_on(:year)
    end

    it "cannot change year to frozen period" do
      record = TimeRecord.create!(group: groups(:be), year: 2016, type: "TimeRecord::EmployeeTime")
      record.year = 2015
      expect(record).to have(1).error_on(:year)
    end

    it "cannot destroy record in frozen year" do
      record = TimeRecord.create!(group: groups(:be), year: 2016, type: "TimeRecord::EmployeeTime")
      record.update_column(:year, 2015)
      expect { record.destroy }.not_to change { TimeRecord.count }
    end
  end

  describe "#fp_calculations" do
    it "falls back to Fp2022::TimeRecord::Calculation for year 2024" do
      rec = described_class.new(year: 2024)

      result = rec.fp_calculations

      expect(result.class.name).to eq("Fp2022::TimeRecord::Calculation")
    end
    it "resolves to Fp2022::TimeRecord::Calculation for year 2022" do
      rec = described_class.new(year: 2022)

      result = rec.fp_calculations

      expect(result.class.name).to eq("Fp2022::TimeRecord::Calculation")
    end
        it "resolves to Fp2020::TimeRecord::Calculation for year 2020" do
      rec = described_class.new(year: 2020)

      result = rec.fp_calculations

      expect(result.class.name).to eq("Fp2020::TimeRecord::Calculation")
    end
  end
end
