# frozen_string_literal: true

#  Copyright (c) 2020, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

# siehe auch Vp2015::Export::Tabular::CourseReporting::ClientStatistics
describe Vp2020::Export::Tabular::CourseReporting::ClientStatistics do

  let(:year) { 2020 }
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

    create_course(year, :fr, 'tk',
                  { be: 1, ag: 1, another: 1 })

    create_course(year, :fr, 'sk',
                  { be: 1, ag: 1, another: 1 })

    create_course(year, :fr, 'tp',
                  { be: 1, ag: 1, another: 1 })
  end

  context '#data_rows' do
    let(:data) { exporter.data_rows.to_a }
    let(:nonempty_rows) { data.reject { |row| row.compact.empty? } }

    it 'exports columns for all cantons' do
      expect(exporter.labels.size).to eq(2 + Cantons.short_names.size)
    end

    it 'contains translated headers' do
      expect(exporter.labels).to match_array([
        'Verein / Kurstyp', 'Total',
        'AG', 'AI', 'AR', 'BE', 'BL', 'BS', 'FR', 'GE', 'GL', 'GR', 'JU', 'LU', 'NE',
        'NW', 'OW', 'SG', 'SH', 'SO', 'SZ', 'TG', 'TI', 'UR', 'VD', 'VS', 'ZG', 'ZH',
        'Andere Herkunft',
      ])
    end

    it 'exports rows for each group' do
      groups = Event::CourseRecord.where(year: year, subventioniert: true).left_joins(event: [:groups])
                                  .flat_map { |ecr| ecr.event.group_ids }.uniq

      expect(nonempty_rows.size).to eq(5 * groups.size)
    end

    it 'contains correct sums' do
      #                                                 'Sum' 'AG' 'AI' 'AR' 'BE' 'BL' 'BS' 'FR' 'GE' 'GL' 'GR' 'JU' 'LU' 'NE' 'NW' 'OW' 'SG' 'SH' 'SO' 'SZ' 'TG' 'TI' 'UR' 'VD' 'VS' 'ZG' 'ZH' 'Andere Herkunft'
      expect(data[ 0]).to eq(['Kanton Bern',              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 1]).to eq(['Semester-/Jahreskurse',    nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 2]).to eq(['Blockkurse',                44,   9, nil, nil,   4, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,  13,  18])
      expect(data[ 3]).to eq(['Tageskurse',               nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 4]).to eq(['Treffpunkte',              nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 5]).to eq([nil,                        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 6]).to eq(['Freiburg',                 nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 7]).to eq(['Semester-/Jahreskurse',      3,   1, nil, nil,   1, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   1])
      expect(data[ 8]).to eq(['Blockkurse',               nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
      expect(data[ 9]).to eq(['Tageskurse',                 3,   1, nil, nil,   1, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   1])
      expect(data[10]).to eq(['Treffpunkte',                3,   1, nil, nil,   1, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,   1])
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
    r.update!(teilnehmende_mehrfachbehinderte: challenged.values.sum / 2)
  end
end
