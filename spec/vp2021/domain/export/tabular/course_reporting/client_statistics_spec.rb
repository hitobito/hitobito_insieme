# frozen_string_literal: true

#  Copyright (c) 2021-2022, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

# siehe auch Vp2015::Export::Tabular::CourseReporting::ClientStatistics
describe Vp2021::Export::Tabular::CourseReporting::ClientStatistics do

  let(:year) { 2021 }
  let(:stats) { vp_class('CourseReporting::ClientStatistics').new(year) }

  let(:exporter) { described_class.new(stats) }

  before do
    create_course(year, :be, 'bk',
                  { be: 1, ag: 2, zh: 3, another: 4 },
                  { be: 0, ag: 1, zh: 1, another: 2 })

    create_course(year, :be, 'bk',
                  { be: 2, ag: 4, zh: 6, another: 8 },
                  { be: 1, ag: 2, zh: 3, another: 4 },
                  :aggregate_course)
      .yield_self do |course, course_record|
        course_record.update!(absenzen_weitere: 1) # leaving only (4 - 1 = 3) "NB" in this course
      end

    create_course(year, :be, 'tp',
                  { be: 1, ag: 1, another: 1 },
                  { be: 2, ag: 2, another: 2 },
                  :aggregate_course)
      .yield_self do |course, course_record|
        course_record.update!(teilnehmende_weitere: 200)
      end

    create_course(year, :fr, 'tk',
                  { be: 1, ag: 1, another: 1 })

    create_course(year, :fr, 'sk',
                  { be: 1, ag: 1, another: 1 })

    create_course(year, :fr, 'tp',
                  { be: 1, ag: 1, another: 1 })
      .yield_self do |course, course_record|
        course_record.update!(teilnehmende_weitere: 200)
      end

    2.times { create_course(year, :fr, 'sk', {}, {}, :course) }

    3.times {
      create_course(year, :fr, 'sk', {}, {}, :course)
        .yield_self do |course, course_record|
          course.update!(fachkonzept: 'autonomie_foerderung')
        end
    }

    4.times { create_course(year, :fr, 'sk', {}, {}, :aggregate_course) }

    1.times do # 1 aggregate_course, counting as 5
      create_course(year, :fr, 'sk', {}, {}, :aggregate_course)
        .yield_self do |course, course_record|
          course.update!(fachkonzept: 'autonomie_foerderung')
          course_record.update!(anzahl_kurse: 5)
        end
    end
  end

  context '#data_rows' do
    let(:data) { exporter.data_rows.to_a }
    let(:nonempty_rows) { data.reject { |row| row.compact.empty? } }

    it 'exports columns for all cantons' do
      prefix = [
        'Verein / Kurstyp',
        'Kursinhalt',
        'Anzahl Kurse',
        'LE Beitragsberechtigte',
        'LE Nicht Beitragsberechtigte',
        'Total'
      ]
      expect(exporter.labels.size).to eq(prefix.size + Cantons.short_names.size)
    end

    it 'contains translated headers' do
      expect(exporter.labels).to match_array([
        'Verein / Kurstyp', 'Kursinhalt', 'Anzahl Kurse', 'LE Beitragsberechtigte', 'LE Nicht Beitragsberechtigte', 'Total',
        'AG', 'AI', 'AR', 'BE', 'BL', 'BS', 'FR', 'GE', 'GL', 'GR', 'JU', 'LU', 'NE',
        'NW', 'OW', 'SG', 'SH', 'SO', 'SZ', 'TG', 'TI', 'UR', 'VD', 'VS', 'ZG', 'ZH',
        'Andere Herkunft',
      ])
    end

    it 'exports rows for each group' do
      groups = Group.by_bsv_number

      expect(nonempty_rows.size).to eq((1 + (2*3) + 1) * groups.size)
    end

    it 'contains correct sums' do
      #                                                         'kursinhalt'    Kurse  Std  NB  'Sum' 'AG' 'AI' 'AR' 'BE' 'BL' 'BS' 'FR' 'GE' 'GL' 'GR' 'JU' 'LU' 'NE' 'NW' 'OW' 'SG' 'SH' 'SO' 'SZ' 'TG' 'TI' 'UR' 'VD' 'VS' 'ZG' 'ZH' 'Andere Herkunft'
      expect(data[ 0]).to match_array(['insieme Schweiz',       2343,             nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 1]).to match_array(['Semester-/Jahreskurse', 'Weiterbildung',  nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 2]).to match_array(['Semester-/Jahreskurse', 'Sport/Freizeit', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 3]).to match_array(['Blockkurse',            'Weiterbildung',  nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 4]).to match_array(['Blockkurse',            'Sport/Freizeit', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 5]).to match_array(['Tageskurse',            'Weiterbildung',  nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 6]).to match_array(['Tageskurse',            'Sport/Freizeit', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 7]).to match_array(['Treffpunkte',           'Treffpunkt',     nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 8]).to match_array([nil,                     nil,              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 9]).to match_array(['Kanton Bern',           2024,             nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[10]).to match_array(['Semester-/Jahreskurse', 'Weiterbildung',  nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[11]).to match_array(['Semester-/Jahreskurse', 'Sport/Freizeit', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[12]).to match_array(['Blockkurse',            'Weiterbildung',  nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[13]).to match_array(['Blockkurse',            'Sport/Freizeit',   2,  28,   5,  44,   9, nil, nil,   4, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  13,  18])
      expect(data[14]).to match_array(['Tageskurse',            'Weiterbildung',  nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[15]).to match_array(['Tageskurse',            'Sport/Freizeit', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[16]).to match_array(['Treffpunkte',           'Treffpunkt',       1, nil, nil,   9,   3, nil, nil,   3, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   3])
      expect(data[17]).to match_array([nil,                     nil,              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[18]).to match_array(['Biel-Seeland',          3115,             nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[19]).to match_array(['Semester-/Jahreskurse', 'Weiterbildung',  nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[20]).to match_array(['Semester-/Jahreskurse', 'Sport/Freizeit', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[21]).to match_array(['Blockkurse',            'Weiterbildung',  nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[22]).to match_array(['Blockkurse',            'Sport/Freizeit', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[23]).to match_array(['Tageskurse',            'Weiterbildung',  nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[24]).to match_array(['Tageskurse',            'Sport/Freizeit', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[25]).to match_array(['Treffpunkte',           'Treffpunkt',     nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[26]).to match_array([nil,                     nil,              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[27]).to match_array(['Freiburg',              12607,            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[28]).to match_array(['Semester-/Jahreskurse', 'Weiterbildung',    8,   0, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[29]).to match_array(['Semester-/Jahreskurse', 'Sport/Freizeit',   7,   6, nil,   3,   1, nil, nil,   1, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   1])
      expect(data[30]).to match_array(['Blockkurse',            'Weiterbildung',  nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[31]).to match_array(['Blockkurse',            'Sport/Freizeit', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[32]).to match_array(['Tageskurse',            'Weiterbildung',  nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[33]).to match_array(['Tageskurse',            'Sport/Freizeit',   1,   6, nil,   3,   1, nil, nil,   1, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   1])
      expect(data[34]).to match_array(['Treffpunkte',           'Treffpunkt',       1, nil, nil,   3,   1, nil, nil,   1, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   1])
      #                                                         'kursinhalt'    Kurse  Std  NB  'Sum' 'AG' 'AI' 'AR' 'BE' 'BL' 'BS' 'FR' 'GE' 'GL' 'GR' 'JU' 'LU' 'NE' 'NW' 'OW' 'SG' 'SH' 'SO' 'SZ' 'TG' 'TI' 'UR' 'VD' 'VS' 'ZG' 'ZH' 'Andere Herkunft'
    end
  end

  it 'contain correct sums according to client-setup' do
    year = 2021
    stats = vp_class('CourseReporting::ClientStatistics').new(year)
    exporter = described_class.new(stats)

    create_course(year, :seeland, 'sk', { be: 15 }).tap do |course, record|
      course.update!(fachkonzept: 'autonomie_foerderung')
      record.update!(
        kursart: 'weiterbildung',
        kursdauer: 10,
        teilnehmende_weitere: 1
      )
    end

    create_course(year, :seeland, 'bk', { be: 40 }, { be: 10}, :aggregate_course).tap do |course, record|
      record.update!(
        anzahl_kurse: 3,
        kursdauer: 15,
        teilnehmende_weitere: 0,
        absenzen_behinderte: 5.0,
        tage_behinderte: 30.0,
        tage_angehoerige: 15.0,
        tage_weitere: 3.0
      )
    end

    create_course(year, :seeland, 'tk', { be: 20 }).tap do |_, record|
      record.update!({
        kursdauer: 1,
        teilnehmende_weitere: 0
      })
    end

    create_course(year, :seeland, 'tp', { be: 20 }, {}, :aggregate_course).tap do |course, record|
      record.update!(
        anzahl_kurse: 5,
        kursdauer: 50,
        tage_weitere: 17, # shall not be reflected in the output
        betreuerinnen: 5,
        betreuungsstunden: 75
      )
    end

    data = exporter.data_rows.to_a

    #                                      Verein / Kurstyp         Kursinhalt        Anz  LE   NB  Total
    expect(data[18][0..5]).to match_array(['Biel-Seeland',          3115,             nil, nil, nil, nil])
    expect(data[19][0..5]).to match_array(['Semester-/Jahreskurse', 'Weiterbildung',    1, 150,  10,  15])
    expect(data[20][0..5]).to match_array(['Semester-/Jahreskurse', 'Sport/Freizeit', nil, nil, nil, nil])
    expect(data[21][0..5]).to match_array(['Blockkurse',            'Weiterbildung',  nil, nil, nil, nil])
    expect(data[22][0..5]).to match_array(['Blockkurse',            'Sport/Freizeit',   3,  45,   3,  50])
    expect(data[23][0..5]).to match_array(['Tageskurse',            'Weiterbildung',  nil, nil, nil, nil])
    expect(data[24][0..5]).to match_array(['Tageskurse',            'Sport/Freizeit',   1,  20, nil,  20])
    expect(data[25][0..5]).to match_array(['Treffpunkte',           'Treffpunkt',       5,  75, nil,  20])
  end

  it 'calculates aggregate_courses correctly' do
    year = 2021
    stats = vp_class('CourseReporting::ClientStatistics').new(year)
    exporter = described_class.new(stats)

    create_course(year, :seeland, 'sk', {}, {}, :course).tap do |course, course_record|
      course.update!(fachkonzept: 'autonomie_foerderung')
    end

    create_course(year, :seeland, 'sk', {}, {}, :course).tap do |course, course_record|
      course.update!(fachkonzept: 'autonomie_foerderung')
    end

    create_course(year, :seeland, 'sk', {}, {}, :course).tap do |course, course_record|
      course.update!(fachkonzept: 'autonomie_foerderung')
    end

    create_course(year, :seeland, 'sk', {}, {}, :aggregate_course).tap do |course, record|
      course.update!(fachkonzept: 'autonomie_foerderung')
      record.update!(
        anzahl_kurse: 3,
      )
    end

    gcp = stats.group_participants(groups(:seeland).id, 'sk', 'weiterbildung')
    expect(gcp.course_count).to eq 6

    data = exporter.data_rows.to_a

    #                                      Verein / Kurstyp         Kursinhalt        Anz  LE   NB  Total
    expect(data[18][0..5]).to match_array(['Biel-Seeland',          3115,             nil, nil, nil, nil])
    expect(data[19][0..5]).to match_array(['Semester-/Jahreskurse', 'Weiterbildung',    6,   0, nil, nil])
    expect(data[20][0..5]).to match_array(['Semester-/Jahreskurse', 'Sport/Freizeit', nil, nil, nil, nil])
    expect(data[21][0..5]).to match_array(['Blockkurse',            'Weiterbildung',  nil, nil, nil, nil])
    expect(data[22][0..5]).to match_array(['Blockkurse',            'Sport/Freizeit', nil, nil, nil, nil])
    expect(data[23][0..5]).to match_array(['Tageskurse',            'Weiterbildung',  nil, nil, nil, nil])
    expect(data[24][0..5]).to match_array(['Tageskurse',            'Sport/Freizeit', nil, nil, nil, nil])
    expect(data[25][0..5]).to match_array(['Treffpunkte',           'Treffpunkt',     nil, nil, nil, nil])
  end

  context 'adds a part of a grundlagenarbeit to treffpunkt LE, it' do
    subject(:gcp) do
      Vp2021::CourseReporting::ClientStatistics::GroupCantonParticipant.new(
        groups(:be).id, 'tp', 'treffpunkt', 5, 75, 0, *Array.new(27) { 0 }
      )
    end

    before :each do
      TimeRecord::EmployeeTime.create!(group_id: gcp.group_id, year: year, kurse_grundlagen: 20)
      TimeRecord::VolunteerWithoutVerificationTime.create!(group_id: gcp.group_id, year: year, kurse_grundlagen: 44)
    end

    context 'has assumptions, the implementation' do
      it 'sums the grundlagenarbeit' do
        grundlagen = ::TimeRecord.where(
          group_id: gcp.group_id,
          year: year,
          type: %w(
            TimeRecord::EmployeeTime
            TimeRecord::VolunteerWithVerificationTime
          )
        ).sum(:kurse_grundlagen).to_f
        expect(grundlagen).to eq 20
      end

      it 'fetches various parts from the kostenrechnung and sums them' do
        kostenrechnung = vp_class('CostAccounting::Table').new(Group.find(gcp.group_id), year)

        expect(kostenrechnung).to receive(:value_of).with('vollkosten', 'jahreskurse').and_return(1495.24.to_d)
        expect(kostenrechnung).to receive(:value_of).with('vollkosten', 'blockkurse').and_return(4990.48.to_d)
        expect(kostenrechnung).to receive(:value_of).with('vollkosten', 'tageskurse').and_return(1497.62.to_d)
        expect(kostenrechnung).to receive(:value_of).with('vollkosten', 'treffpunkte').and_return(3244.05.to_d)

        total = [
          kostenrechnung.value_of('vollkosten', 'jahreskurse'),
          kostenrechnung.value_of('vollkosten', 'blockkurse'),
          kostenrechnung.value_of('vollkosten', 'tageskurse'),
          kostenrechnung.value_of('vollkosten', 'treffpunkte'),
        ].map(&:to_f).sum

        expect(total).to be_within(0.01).of(11227.39)
      end

      it 'derives the anteil from the kostenrechnung' do
        anteil = 20.to_f * (3244.05.to_f / 11227.39.to_f)

        expect(anteil).to be_within(0.001).of(5.77881413222485)
      end

      it 'takes the leistungseinheiten from the group-client-statistic-data' do
        expect(gcp.course_hours.to_f).to eq 75
      end

      it 'adds the anteil to the leistungseinheiten' do
        result = 75 + 5.778
        expect(result).to be_within(0.001).of(80.778)
      end
    end

    it 'matches the actual implementation result' do
      # collaborators
      kostenrechnung = double("CostAccounting-Table")
      stats = double('client-statistics')

      # return-values from collbarators
      allow(stats).to receive(:year).and_return(year) # from let above
      expect(kostenrechnung).to receive(:value_of).with('vollkosten', 'jahreskurse').and_return(1495.24.to_d)
      expect(kostenrechnung).to receive(:value_of).with('vollkosten', 'blockkurse').and_return(4990.48.to_d)
      expect(kostenrechnung).to receive(:value_of).with('vollkosten', 'tageskurse').and_return(1497.62.to_d)
      expect(kostenrechnung).to receive(:value_of).with('vollkosten', 'treffpunkte').and_return(3244.05.to_d)

      # wire collaborators together
      expect(vp_class('CostAccounting::Table')).to receive(:new).with(Group.find(gcp.group_id), year).and_return(kostenrechnung)

      # execute
      result = described_class.new(stats)
                              .send(:kursdauer_und_treffpunkt_grundlagenanteil, gcp)

      expect(result).to be_within(0.001).of(80.778)
    end
  end

  private

  def create_course(year, group, leistungskategorie, challenged = {}, affiliated = {}, event_type = :course)
    event = nil
    fachkonzept = leistungskategorie == 'tp' ? 'treffpunkt' : 'sport_jugend'
    if event_type == :aggregate_course
      event = Fabricate(event_type,
                        leistungskategorie: leistungskategorie,
                        fachkonzept: fachkonzept,
                        year: year)
      event.update(group_ids: [groups(group).id])
    else
      event = Fabricate(event_type,
                        leistungskategorie: leistungskategorie, fachkonzept: fachkonzept)
      event.update(group_ids: [groups(group).id])
      event.dates.create!(start_at: Time.zone.local(year, 05, 11))
    end
    r = Event::CourseRecord.create!(event_id: event.id, year: year)
    r.create_challenged_canton_count!(challenged) if challenged.present?
    r.create_affiliated_canton_count!(affiliated) if affiliated.present?
    r.update!({
      kursdauer: 2,
      teilnehmende_mehrfachbehinderte: challenged.values.sum / 2,
      teilnehmende_weitere: (challenged.values.sum / 10).floor
    })
    [event, r]
  end
end
