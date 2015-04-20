# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe CourseReporting::ClientStatistics do

  before do
    create_course(2015, :be, 'bk',
                  { be: 1, ag: 2, zh: 3, other: 4 },
                  { be: 0, ag: 1, zh: 1, other: 2 })

    create_course(2015, :be, 'bk',
                  { be: 2, ag: 4, zh: 6, other: 8 },
                  { be: 1, ag: 2, zh: 3, other: 4 },
                  :aggregate_course)

    create_course(2015, :fr, 'bk',
                  { be: 3, ag: 3, zh: 3, tg: 3, other: 3 })

    create_course(2015, :fr, 'tk',
                  { be: 1, ag: 1, other: 1 })

    create_course(2015, :fr, 'tk',
                  { be: 1, zh: 1, other: 1 })

    # other year
    create_course(2014, :fr, 'bk',
                  { be: 4, ag: 4, zh: 4, tg: 4, other: 4 },
                  { be: 2, ag: 2, zh: 2, other: 2 })
  end

  let(:stats) { described_class.new(2015) }

  it 'contains summed values' do
    expect(stats.canton_count(:be, 'bk', :challenged)).to eq(6)
    expect(stats.canton_count(:be, 'bk', :affiliated)).to eq(1)
    expect(stats.canton_count(:ag, 'bk', :challenged)).to eq(9)
    expect(stats.canton_count(:ag, 'bk', :affiliated)).to eq(3)
    expect(stats.canton_count(:zh, 'bk', :challenged)).to eq(12)
    expect(stats.canton_count(:zh, 'bk', :affiliated)).to eq(4)
    expect(stats.canton_count(:tg, 'bk', :challenged)).to eq(3)
    expect(stats.canton_count(:tg, 'bk', :affiliated)).to eq(0)
    expect(stats.canton_count(:other, 'bk', :challenged)).to eq(15)
    expect(stats.canton_count(:other, 'bk', :affiliated)).to eq(6)

    expect(stats.canton_count(:be, 'tk', :challenged)).to eq(2)
    expect(stats.canton_count(:be, 'tk', :affiliated)).to eq(0)
    expect(stats.canton_count(:ag, 'tk', :challenged)).to eq(1)
    expect(stats.canton_count(:ag, 'tk', :affiliated)).to eq(0)
    expect(stats.canton_count(:zh, 'tk', :challenged)).to eq(1)
    expect(stats.canton_count(:zh, 'tk', :affiliated)).to eq(0)
    expect(stats.canton_count(:tg, 'tk', :challenged)).to eq(0)
    expect(stats.canton_count(:tg, 'tk', :affiliated)).to eq(0)
    expect(stats.canton_count(:other, 'tk', :challenged)).to eq(2)
    expect(stats.canton_count(:other, 'tk', :affiliated)).to eq(0)

    expect(stats.canton_count(:be, 'sk', :challenged)).to eq(0)
    expect(stats.canton_count(:be, 'sk', :affiliated)).to eq(0)
    expect(stats.canton_count(:other, 'sk', :challenged)).to eq(0)
    expect(stats.canton_count(:other, 'sk', :affiliated)).to eq(0)
  end

  it 'has correct totals' do
    expect(stats.canton_total('bk', :challenged)).to eq(45)
    expect(stats.canton_total('bk', :affiliated)).to eq(14)

    expect(stats.canton_total('tk', :challenged)).to eq(6)
    expect(stats.canton_total('tk', :affiliated)).to eq(0)

    expect(stats.canton_total('sk', :challenged)).to eq(0)
    expect(stats.canton_total('sk', :affiliated)).to eq(0)
  end

  it 'has correct participant counts' do
    expect(stats.participant_count('bk', :challenged)).to eq(45)
    expect(stats.participant_count('bk', :affiliated)).to eq(14)
    expect(stats.participant_count('bk', :multiple)).to eq(14)

    expect(stats.participant_count('tk', :challenged)).to eq(6)
    expect(stats.participant_count('tk', :affiliated)).to eq(0)
    expect(stats.participant_count('tk', :multiple)).to eq(2)

    expect(stats.participant_count('sk', :challenged)).to eq(0)
    expect(stats.participant_count('sk', :affiliated)).to eq(0)
    expect(stats.participant_count('sk', :multiple)).to eq(0)
  end

  private

  def create_course(year, group, leistungskategorie, challenged = {}, affiliated = {}, event_type = :course)
    event = Fabricate(event_type,
                      group_ids: [groups(group).id],
                      leistungskategorie: leistungskategorie)
    event.dates.create!(start_at: Time.zone.local(year, 05, 11))
    r = Event::CourseRecord.create!(event_id: event.id, year: year)
    r.create_challenged_canton_count!(challenged) if challenged.present?
    r.create_affiliated_canton_count!(affiliated) if affiliated.present?
    r.update!(teilnehmende_mehrfachbehinderte: challenged.values.sum / 3)
  end

end