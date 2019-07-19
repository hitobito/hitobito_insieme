# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Export::Tabular::CourseReporting::ClientStatistics do

  let(:stats) { CourseReporting::ClientStatistics.new(2015) }

  let(:exporter) { described_class.new(stats) }

  before do
    create_course(2015, :be, 'bk',
                  { be: 1, ag: 2, zh: 3, another: 4 },
                  { be: 0, ag: 1, zh: 1, another: 2 })

    create_course(2015, :be, 'bk',
                  { be: 2, ag: 4, zh: 6, another: 8 },
                  { be: 1, ag: 2, zh: 3, another: 4 },
                  :aggregate_course)

    create_course(2015, :fr, 'tk',
                  { be: 1, ag: 1, another: 1 })

    create_course(2015, :fr, 'sk',
                  { be: 1, ag: 1, another: 1 })

    create_course(2015, :fr, 'tp',
                  { be: 1, ag: 1, another: 1 })
  end

  context '#data_rows' do
    let(:data) { exporter.data_rows.to_a }

    it 'exports data for all cantons' do
      expect(data.size).to eq(2 + Cantons.short_names.size + 1)
    end

    it 'contains correct sums' do
      expect(data[0]).to eq(['Geistig-/Lernbehinderte',  30,  14, 3,   0, 3,   0, 3,   0])
      expect(data[1]).to eq(['davon Mehrfachbehinderte', 15, nil, 1, nil, 1, nil, 1, nil])
      expect(data[2]).to eq(['Aargau',                    6,   3, 1,   0, 1,   0, 1,   0])
      expect(data[3]).to eq(['Appenzell Innerrhoden',     0,   0, 0,   0, 0,   0, 0,   0])
      expect(data[5]).to eq(['Bern',                      3,   1, 1,   0, 1,   0, 1,   0])
      expect(data.last).to eq(['Total',                  30,  14, 3,   0, 3,   0, 3,   0])
    end

    it 'contains translated headers' do
      expect(exporter.labels).to eq(['Behinderung / Kanton',
                                'Blockkurse Anzahl Behinderte (Personen)',
                                'Blockkurse Anzahl Angehörige (Personen)',
                                'Tageskurse Anzahl Behinderte (Personen)',
                                'Tageskurse Anzahl Angehörige (Personen)',
                                'Semester-/Jahreskurse Anzahl Behinderte (Personen)',
                                'Semester-/Jahreskurse Anzahl Angehörige (Personen)',
                                'Treffpunkte Anzahl Behinderte (Personen)',
                                'Treffpunkte Anzahl Angehörige (Personen)',
                                ])
    end

  end

  private

  def create_course(year, group, leistungskategorie, challenged = {}, affiliated = {}, event_type = :course)
    event = nil
    if event_type == :aggregate_course
      event = Fabricate(event_type,
                        group_ids: [groups(group).id],
                        leistungskategorie: leistungskategorie,
                        year: year)
    else
      event = Fabricate(event_type,
                        group_ids: [groups(group).id],
                        leistungskategorie: leistungskategorie)
      event.dates.create!(start_at: Time.zone.local(year, 05, 11))
    end
    r = Event::CourseRecord.create!(event_id: event.id, year: year)
    r.create_challenged_canton_count!(challenged) if challenged.present?
    r.create_affiliated_canton_count!(affiliated) if affiliated.present?
    r.update!(teilnehmende_mehrfachbehinderte: challenged.values.sum / 2)
  end

end
