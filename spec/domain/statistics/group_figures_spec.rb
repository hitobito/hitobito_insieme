# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Statistics::GroupFigures do

  before do
    TimeRecord::EmployeeTime.create!(group: groups(:be), year: 2015, interviews: 10, nicht_art_74_leistungen: 5)
    TimeRecord::EmployeeTime.create!(group: groups(:be), year: 2014, newsletter: 11)
    TimeRecord::EmployeeTime.create!(group: groups(:fr), year: 2015, projekte: 12)

    TimeRecord::VolunteerWithVerificationTime.create!(
      group: groups(:be), year: 2015, vermittlung_kontakte: 20)
    TimeRecord::VolunteerWithVerificationTime.create!(
      group: groups(:fr), year: 2015, referate: 21)

    TimeRecord::VolunteerWithoutVerificationTime.create!(
      group: groups(:be), year: 2015, total_lufeb_promoting: 30)

    CostAccountingRecord.create!(group: groups(:be), year: 2015, report: 'raumaufwand',
                                 raeumlichkeiten: 100)
    CostAccountingRecord.create!(group: groups(:be), year: 2015, report: 'honorare',
                                 aufwand_ertrag_fibu: 100, verwaltung: 10,
                                 beratung: 30, tageskurse: 10)
    CostAccountingRecord.create!(group: groups(:be), year: 2015, report: 'leistungsertrag',
                                 aufwand_ertrag_fibu: 100, abgrenzung_fibu: 80,
                                 lufeb: 20)
    CostAccountingRecord.create!(group: groups(:be), year: 2015, report: 'direkte_spenden',
                                 aufwand_ertrag_fibu: 10, lufeb: 2, tageskurse: 8)
    CostAccountingRecord.create!(group: groups(:be), year: 2015, report: 'beitraege_iv',
                                 aufwand_ertrag_fibu: 100, abgrenzung_fibu: 80,
                                 lufeb: 20)

    CapitalSubstrate.create!(
      group: groups(:be), year: 2015, organization_capital: 500_000, fund_building: 25_000)
    CapitalSubstrate.create!(
      group: groups(:be), year: 2014, organization_capital: 200_000, fund_building: 15_000)

    create_course(2015, :be, 'bk', '1', kursdauer: 10, challenged_canton_count_attributes: { zh: 100 }, unterkunft: 500)
    create_course(2015, :be, 'bk', '1', kursdauer: 11, affiliated_canton_count_attributes: { zh: 101 }, gemeinkostenanteil: 600)
    create_course(2015, :be, 'bk', '2', kursdauer: 12, challenged_canton_count_attributes: { zh: 450 }, unterkunft: 800)
    create_course(2015, :be, 'bk', '3', kursdauer: 13, teilnehmende_weitere: 650, uebriges: 200)
    create_course(2015, :be, 'sk', '1', kursdauer: 14, challenged_canton_count_attributes: { zh: 102 }, unterkunft: 400)
    create_course(2015, :fr, 'bk', '1', kursdauer: 15, challenged_canton_count_attributes: { zh: 103 }, unterkunft: 0)
    create_course(2015, :fr, 'tk', '1', kursdauer: 16, teilnehmende_weitere: 104, unterkunft: 500)
    create_course(2015, :fr, 'tk', '3', kursdauer: 17, challenged_canton_count_attributes: { zh: 500 }, uebriges: 600)

    # other year
    create_course(2014, :fr, 'bk', '1', kursdauer: 17, teilnehmende_weitere: 105)

    @course_records = Event::CourseRecord.joins(:event).where(year: 2015)
  end

  let(:figures) { described_class.new(2015) }

  context '#groups' do
    it 'returns group sorted by type' do
      expect(figures.groups).to eq [groups(:dachverein),
                                    groups(:fr),
                                    groups(:be),
                                    groups(:seeland)]
    end
  end



  context '#participant_efforts' do
    it 'returns the summed totals' do
      %w(be fr).product(%w(bk sk), %w(1 2 3)).each do |group_key, lk, zk|
        group = groups(group_key)
        records = course_records(group, lk, zk)
        expected = records.sum(&:total_tage_teilnehmende)
        record = figures.course_record(groups(group_key), lk, zk)
        actual = record.try(:total_tage_teilnehmende).to_i
        msg = "expected figures.course_record(#{group_key}, #{lk}, #{zk}).total_tage_teilnehmende to eq #{expected}, got: #{actual}"

        expect(actual).to eq(expected), msg
      end

      record = figures.course_record(groups(:be), 'bk', '1')
      expect(record.total_tage_teilnehmende).to eq(10 * 100 + 11 * 101)
      expect(record.tage_behinderte).to eq(10 * 100)
      expect(record.tage_angehoerige).to eq(11 * 101)
      expect(record.tage_weitere).to eq(0)
      expect(record.anzahl_kurse).to eq(2)
      expect(record.total_vollkosten).to eq(500 + 600)

      record = figures.course_record(groups(:be), 'bk', '2')
      expect(record.total_tage_teilnehmende).to eq(12 * 450)
      expect(record.tage_behinderte).to eq(12 * 450)
      expect(record.anzahl_kurse).to eq(1)
      expect(record.total_vollkosten).to eq(800)

      record = figures.course_record(groups(:be), 'bk', '3')
      expect(record.total_tage_teilnehmende).to eq(13 * 650)
      expect(record.tage_weitere).to eq(13 * 650)

      expect(figures.course_record(groups(:be), 'tk', '1')).to be_nil
      expect(figures.course_record(groups(:be), 'tk', '2')).to be_nil
      expect(figures.course_record(groups(:be), 'tk', '3')).to be_nil

      record = figures.course_record(groups(:be), 'sk', '1')
      expect(record.total_tage_teilnehmende).to eq(14 * 102)

      record = figures.course_record(groups(:fr), 'bk', '1')
      expect(record.total_tage_teilnehmende).to eq(15 * 103)

      expect(figures.course_record(groups(:fr), 'bk', '2')).to be_nil
      expect(figures.course_record(groups(:fr), 'bk', '3')).to be_nil

      record = figures.course_record(groups(:fr), 'tk', '1')
      expect(record.total_tage_teilnehmende).to eq(16 * 104)

      expect(figures.course_record(groups(:fr), 'tk', '2')).to be_nil

      record = figures.course_record(groups(:fr), 'tk', '3')
      expect(record.total_tage_teilnehmende).to eq(17 * 500)

      expect(figures.course_record(groups(:fr), 'sk', '1')).to be_nil
    end

    it 'returns nil for groups without records' do
      expect(figures.course_record(groups(:seeland), 'bk', '1')).to be_nil
    end
  end

  context '#employee_time' do
    it 'returns the totals' do
      time = figures.employee_time(groups(:be))
      expect(time.total_lufeb).to eq(10)
      expect(time.total_lufeb_general).to eq(10)
      time = figures.employee_time(groups(:fr))
      expect(time.total_lufeb).to eq(12)
      expect(time.total_lufeb_specific).to eq(12)

      expect(figures.employee_time(groups(:be)).total_lufeb).to eq(employee_total_lufeb(:be))
      expect(figures.employee_time(groups(:fr)).total_lufeb).to eq(employee_total_lufeb(:fr))
    end

    it 'returns the pensums' do
      time = figures.employee_time(groups(:be))
      expect(time.total_pensum).to eq(15.to_d/1900)
      expect(time.total_paragraph_74_pensum).to eq(10.to_d/1900)

      time = figures.employee_time(groups(:fr))
      expect(time.total_pensum).to eq(12.to_d/1900)
      expect(time.total_paragraph_74_pensum).to eq(12.to_d/1900)
    end

    it 'returns nil for groups without records' do
      expect(figures.employee_time(groups(:seeland))).to be_nil
    end
  end

  context '#volunteer_with_verification_time' do
    it 'returns the totals' do
      time = figures.volunteer_with_verification_time(groups(:be))
      expect(time.total_lufeb).to eq(20)
      expect(time.total_lufeb_promoting).to eq(20)
      time = figures.volunteer_with_verification_time(groups(:fr))
      expect(time.total_lufeb).to eq(21)
      expect(time.total_lufeb_general).to eq(21)

      expect(figures.volunteer_with_verification_time(groups(:be)).total_lufeb).to eq(volunteer_total_lufeb(:be))
      expect(figures.volunteer_with_verification_time(groups(:fr)).total_lufeb).to eq(volunteer_total_lufeb(:fr))
    end

    it 'returns the pensums' do
      time = figures.volunteer_with_verification_time(groups(:be))
      expect(time.total_pensum).to eq(20.to_d/1900)
      expect(time.total_paragraph_74_pensum).to eq(20.to_d/1900)

      time = figures.volunteer_with_verification_time(groups(:fr))
      expect(time.total_pensum).to eq(21.to_d/1900)
      expect(time.total_paragraph_74_pensum).to eq(21.to_d/1900)
    end

    it 'returns nil for groups without records' do
      expect(figures.volunteer_with_verification_time(groups(:seeland))).to be_nil
    end
  end

  context '#volunteer_without_verification_time' do
    it 'returns the totals' do
      time = figures.volunteer_without_verification_time(groups(:be))
      expect(time.total_lufeb).to eq(30)
      expect(time.total_lufeb_promoting).to eq(30)
    end

    it 'returns nil for groups without records' do
      expect(figures.volunteer_without_verification_time(groups(:seeland))).to be_nil
    end
  end

  context 'capital substrate' do
    it 'returns the correct substrate' do
      substrate = figures.capital_substrate(groups(:be))
      expect(substrate.paragraph_74).to eq(574_950.0)
    end

    it 'returns negative exemption for groups without records' do
      expect(figures.capital_substrate(groups(:seeland)).paragraph_74).to eq(-200_000)
    end

    it 'returns the same substrate like the time record table' do
      substrate = figures.capital_substrate(groups(:be)).paragraph_74
      table = TimeRecord::Table.new(groups(:be), 2015)
      expect(substrate).to eq(table.value_of('capital_substrate', 'paragraph_74'))
    end
  end

  context 'cost accounting' do
    it 'contains the correct values' do
      table = figures.cost_accounting_table(groups(:be))
      expect(table.value_of('total_aufwand', 'aufwand_ertrag_fibu')).to eq(100)
      expect(table.value_of('vollkosten', 'total')).to eq(150)
      expect(table.value_of('beitraege_iv', 'total')).to eq(20)
      expect(table.value_of('deckungsbeitrag4', 'total')).to eq(-100)
    end

    it 'returns nil for groups without records' do
      expect(figures.cost_accounting_table(groups(:seeland))).to be_nil
    end
  end

  private

  def course_records(group, leistungskategorie, zugeteilte_kategorie)
    @course_records.select do |r|
      r.event.groups.first == group &&
      r.event.leistungskategorie == leistungskategorie  &&
      r.zugeteilte_kategorie == zugeteilte_kategorie
    end
  end

  def create_course(year, group_key, leistungskategorie, kategorie, attrs)
    event = Fabricate(:course, groups: [groups(group_key)],
                               leistungskategorie: leistungskategorie)
    event.dates.create!(start_at: Time.zone.local(year, 05, 11))
    r = Event::CourseRecord.create!(attrs.merge(event_id: event.id, year: year))
    r.update_column(:zugeteilte_kategorie, kategorie)
  end

  def employee_total_lufeb(group_key, year = 2015)
    TimeRecord::EmployeeTime.find_by_group_id_and_year(groups(group_key).id, year).total_lufeb
  end

  def volunteer_total_lufeb(group_key, year = 2015)
    TimeRecord::VolunteerWithVerificationTime.find_by_group_id_and_year(groups(group_key).id, year).total_lufeb
  end

end
