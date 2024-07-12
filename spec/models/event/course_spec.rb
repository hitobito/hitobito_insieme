#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Event::Course do
  subject do
    Fabricate(:course, groups: [groups(:dachverein)], leistungskategorie: "bk", fachkonzept: "sport_jugend")
  end

  context "#years" do
    context "within same year" do
      before do
        subject.dates.destroy_all
        subject.dates.create!(start_at: Time.zone.parse("2014-10-01"),
          finish_at: Time.zone.parse("2014-10-03"))
        subject.dates.create!(start_at: Time.zone.parse("2014-11-01"),
          finish_at: Time.zone.parse("2014-11-03"))
      end

      its(:years) { is_expected.to eq [2014] }
    end

    context "multiple years" do
      before do
        subject.dates.destroy_all
        subject.dates.create!(start_at: Time.zone.parse("2013-09-01"),
          finish_at: Time.zone.parse("2013-09-03"))
        subject.dates.create!(start_at: Time.zone.parse("2014-10-01"),
          finish_at: Time.zone.parse("2014-10-03"))
        subject.dates.create!(start_at: Time.zone.parse("2014-12-01"),
          finish_at: Time.zone.parse("2015-01-03"))
        subject.dates.create!(start_at: Time.zone.parse("2015-02-01"),
          finish_at: Time.zone.parse("2015-02-03"))
      end

      its(:years) { is_expected.to eq [2013, 2014, 2015] }
    end
  end

  context "leistungskategorien and fachkonzepte" do
    let(:course) do
      Fabricate(:course, groups: [groups(:dachverein)], leistungskategorie: leistungskategorie, fachkonzept: fachkonzept)
    end

    context "contains Blockkurse" do
      let(:leistungskategorie) { "bk" }
      let(:fachkonzept) { "freizeit_jugend" }

      it "and is valid" do
        expect(course).to be_valid
      end
    end

    context "contains Tageskurse" do
      let(:leistungskategorie) { "tk" }
      let(:fachkonzept) { "freizeit_erwachsen" }

      it "and is valid" do
        expect(course).to be_valid
      end
    end

    context "contains Semesterkurse" do
      let(:leistungskategorie) { "sk" }
      let(:fachkonzept) { "sport_jugend" }

      it "and is valid" do
        expect(course).to be_valid
      end
    end

    context "contains Treffpunkte" do
      let(:leistungskategorie) { "tp" }
      let(:fachkonzept) { "treffpunkt" }

      it "and is valid" do
        expect(course).to be_valid
      end
    end

    context "with combination Treffpunkt and Kurs-Fachkonzept" do
      let(:leistungskategorie) { "tp" }
      let(:fachkonzept) { "freizeit_jugend" }

      it "is invalid" do
        expect { course }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context "with combination Kurs-Kategorie and Treffpunkt-Fachkonzept" do
      let(:leistungskategorie) { "bk" }
      let(:fachkonzept) { "treffpunkt" }

      it "is invalid" do
        expect { course }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end

  context "#available_leistungskategorien" do
    it "translates Blockkurs" do
      expect(described_class.available_leistungskategorien).to include(["bk", "Blockkurs"])
    end

    it "translates Tageskurs" do
      expect(described_class.available_leistungskategorien).to include(["tk", "Tageskurs"])
    end

    it "translates Semesterkurs" do
      expect(described_class.available_leistungskategorien).to include(["sk", "Semester-/Jahreskurs"])
    end

    it "translates Treffpunkt" do
      expect(described_class.available_leistungskategorien).to include(["tp", "Treffpunkt"])
    end
  end

  context "#available_fachkonzepte" do
    it "translates Freizeit Kinder & Jugendliche" do
      expect(described_class.available_fachkonzepte).to include(["freizeit_jugend", "Freizeit Kinder & Jugendliche"])
    end

    it "translates Freizeit Erwachsene & altersdurchmischt" do
      expect(described_class.available_fachkonzepte).to include(["freizeit_erwachsen", "Freizeit Erwachsene & altersdurchmischt"])
    end

    it "translates Sport Kinder & Jugendliche" do
      expect(described_class.available_fachkonzepte).to include(["sport_jugend", "Sport Kinder & Jugendliche"])
    end

    it "translates Sport Erwachsene & altersdurchmischt" do
      expect(described_class.available_fachkonzepte).to include(["sport_erwachsen", "Sport Erwachsene & altersdurchmischt"])
    end

    it "translates Förderung der Autonomie/Bildung" do
      expect(described_class.available_fachkonzepte).to include(["autonomie_foerderung", "Förderung der Autonomie/Bildung"])
    end

    it "translates Treffpunkt" do
      expect(described_class.available_fachkonzepte).to include(["treffpunkt", "Treffpunkt"])
    end
  end
end
