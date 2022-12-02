# frozen_string_literal: true

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Fp2015::Export::Tabular::CourseReporting::ClientStatistics do

  let(:year) { 2015 }
  let(:stats) { fp_class('CourseReporting::ClientStatistics').new(year) }

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

    it 'exports data for all cantons' do
      expect(data.size).to eq(2 + Cantons.short_names.size + 1)
    end

    it 'contains correct sums' do
      expect(data[0]).to eq(['mit geistiger Behinderung/Lernbehinderung',  30,  14, 3,   0, 3,   0, 3,   0])
      expect(data[1]).to eq(['davon Personen mit Mehrfachbehinderung', 15, nil, 1, nil, 1, nil, 1, nil])
      expect(data[2]).to eq(['Aargau',                    6,   3, 1,   0, 1,   0, 1,   0])
      expect(data[3]).to eq(['Appenzell Innerrhoden',     0,   0, 0,   0, 0,   0, 0,   0])
      expect(data[5]).to eq(['Bern',                      3,   1, 1,   0, 1,   0, 1,   0])
      expect(data.last).to eq(['Total',                  30,  14, 3,   0, 3,   0, 3,   0])
    end

    it 'contains translated headers' do
      expect(exporter.labels).to eq(['Personen mit Behinderung / Kanton',
                                'Blockkurse Anzahl Personen mit Behinderung',
                                'Blockkurse Anzahl Angehörige Personen',
                                'Tageskurse Anzahl Personen mit Behinderung',
                                'Tageskurse Anzahl Angehörige Personen',
                                'Semester-/Jahreskurse Anzahl Personen mit Behinderung',
                                'Semester-/Jahreskurse Anzahl Angehörige Personen',
                                'Treffpunkte Anzahl Personen mit Behinderung',
                                'Treffpunkte Anzahl Angehörige Personen',
                                ])
    end

  end

  private

  def create_course(year, group, leistungskategorie, challenged = {}, affiliated = {}, event_type = :course)
    event = nil
    fachkonzept = leistungskategorie == 'tp' ? 'treffpunkt' : 'sport_jugend'
    if event_type == :aggregate_course
      event = Fabricate(event_type,
                        group_ids: [groups(group).id],
                        leistungskategorie: leistungskategorie,
                        fachkonzept: fachkonzept,
                        year: year)
    else
      event = Fabricate(event_type,
                        group_ids: [groups(group).id],
                        leistungskategorie: leistungskategorie, fachkonzept: fachkonzept)
      event.dates.create!(start_at: Time.zone.local(year, 05, 11))
    end
    r = Event::CourseRecord.create!(event_id: event.id, year: year)
    r.create_challenged_canton_count!(challenged) if challenged.present?
    r.create_affiliated_canton_count!(affiliated) if affiliated.present?
    r.update!(teilnehmende_mehrfachbehinderte: challenged.values.sum / 2)
  end

end
