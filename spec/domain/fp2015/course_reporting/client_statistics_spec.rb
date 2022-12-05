# frozen_string_literal: true

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Fp2015::CourseReporting::ClientStatistics do

  before do
    create_course(2015, :be, 'bk',
                  { be: 1, ag: 2, zh: 3, another: 4 },
                  { be: 0, ag: 1, zh: 1, another: 2 })

    create_course(2015, :be, 'bk',
                  { be: 2, ag: 4, zh: 6, another: 8 },
                  { be: 1, ag: 2, zh: 3, another: 4 },
                  true,
                  :aggregate_course)

    create_course(2015, :fr, 'bk',
                  { be: 3, ag: 3, zh: 3, tg: 3, another: 3 })

    create_course(2015, :fr, 'tk',
                  { be: 1, ag: 1, another: 1 })

    create_course(2015, :fr, 'tk',
                  { be: 1, zh: 1, another: 1 })

    # other year
    create_course(2014, :fr, 'bk',
                  { be: 4, ag: 4, zh: 4, tg: 4, another: 4 },
                  { be: 2, ag: 2, zh: 2, another: 2 })

    # same year, non subventioniert
    create_course(2015, :be, 'bk',
                  { be: 1, ag: 2, zh: 3, another: 4 },
                  { be: 0, ag: 1, zh: 1, another: 2 },
                  false)

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
    expect(stats.canton_count(:another, 'bk', :challenged)).to eq(15)
    expect(stats.canton_count(:another, 'bk', :affiliated)).to eq(6)

    expect(stats.canton_count(:be, 'tk', :challenged)).to eq(2)
    expect(stats.canton_count(:be, 'tk', :affiliated)).to eq(0)
    expect(stats.canton_count(:ag, 'tk', :challenged)).to eq(1)
    expect(stats.canton_count(:ag, 'tk', :affiliated)).to eq(0)
    expect(stats.canton_count(:zh, 'tk', :challenged)).to eq(1)
    expect(stats.canton_count(:zh, 'tk', :affiliated)).to eq(0)
    expect(stats.canton_count(:tg, 'tk', :challenged)).to eq(0)
    expect(stats.canton_count(:tg, 'tk', :affiliated)).to eq(0)
    expect(stats.canton_count(:another, 'tk', :challenged)).to eq(2)
    expect(stats.canton_count(:another, 'tk', :affiliated)).to eq(0)

    expect(stats.canton_count(:be, 'sk', :challenged)).to eq(0)
    expect(stats.canton_count(:be, 'sk', :affiliated)).to eq(0)
    expect(stats.canton_count(:another, 'sk', :challenged)).to eq(0)
    expect(stats.canton_count(:another, 'sk', :affiliated)).to eq(0)
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

  def create_course(year, group, leistungskategorie, challenged = {}, affiliated = {},
                    subventioniert = true, event_type = :course)
    event = nil
    if event_type == :aggregate_course
      event = Fabricate(event_type,
                        group_ids: [groups(group).id],
                        leistungskategorie: leistungskategorie,
                        fachkonzept: 'sport_jugend',
                        year: year)
    else
      event = Fabricate(event_type,
                        group_ids: [groups(group).id],
                        leistungskategorie: leistungskategorie,
                        fachkonzept: 'sport_jugend')
      event.dates.create!(start_at: Time.zone.local(year, 05, 11))
    end
    r = Event::CourseRecord.create!(event_id: event.id, year: year, subventioniert: subventioniert)
    r.create_challenged_canton_count!(challenged) if challenged.present?
    r.create_affiliated_canton_count!(affiliated) if affiliated.present?
    r.update!(teilnehmende_mehrfachbehinderte: challenged.values.sum / 3)
  end

end
