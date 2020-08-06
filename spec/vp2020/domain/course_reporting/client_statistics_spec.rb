# frozen_string_literal: true

#  Copyright (c) 2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Vp2020::CourseReporting::ClientStatistics do

  let(:year) { 2020 }
  let(:stats) { described_class.new(year) }

  before do
    create_course(year, :be, 'bk',
                  { be: 1, ag: 2, zh: 3, another: 4 },
                  { be: 0, ag: 1, zh: 1, another: 2 })

    create_course(year, :be, 'bk',
                  { be: 2, ag: 4, zh: 6, another: 8 },
                  { be: 1, ag: 2, zh: 3, another: 4 },
                  true,
                  :aggregate_course)

    create_course(year, :fr, 'bk',
                  { be: 3, ag: 3, zh: 3, tg: 3, another: 3 })

    create_course(year, :fr, 'tk',
                  { be: 1, ag: 1, another: 1 })

    create_course(year, :fr, 'tk',
                  { be: 1, zh: 1, another: 1 })

    # other year
    create_course(year - 1, :fr, 'bk',
                  { be: 4, ag: 4, zh: 4, tg: 4, another: 4 },
                  { be: 2, ag: 2, zh: 2, another: 2 })

    # same year, non subventioniert
    create_course(year, :be, 'bk',
                  { be: 1, ag: 2, zh: 3, another: 4 },
                  { be: 0, ag: 1, zh: 1, another: 2 },
                  false)
  end

  it 'has a list of groups' do
    expect(stats.groups).to be_an Array
    expect(stats.groups.map(&:class).map(&:name).uniq).to eql ['Group::Regionalverein']
    expect(stats.groups.map(&:name).sort).to eql ['Freiburg', 'Kanton Bern']
  end

  it 'knowns the cantons' do
    expect(stats.cantons).to eql %w(
      ag ai ar be bl bs fr ge gl gr ju lu ne
      nw ow sg sh so sz tg ti ur vd vs zg zh
      another
    )
  end

  it 'can load summed values' do
    expect(stats.send(:raw_group_canton_participants).size).to eq(3)
    rows = stats.send(:raw_group_canton_participants)
    gcps = rows.map do |row|
      Vp2020::CourseReporting::ClientStatistics::GroupCantonParticipant.new(*row)
    end

    expect(gcps.size).to eq(3)

    results = gcps.reduce({}) do |memo, gcp|
      memo[gcp.group_id] ||= {}
      memo[gcp.group_id][gcp.leistungskategorie] = gcp
      memo
    end

    expect(results).to be_a Hash
    expect(results.keys).to eq([groups(:fr).id, groups(:be).id].sort)

    expect(stats.send(:group_canton_participants).keys.sort).to eq([groups(:be).id, groups(:fr).id].sort)
  end

  it 'contains summed values per group' do
    expect(stats.group_canton_count(groups(:be).id, :be, 'bk', 'sport')).to eq(4)
    expect(stats.group_canton_count(groups(:be).id, :ag, 'bk', 'sport')).to eq(9)
    expect(stats.group_canton_count(groups(:be).id, :zh, 'bk', 'sport')).to eq(13)
    expect(stats.group_canton_count(groups(:be).id, :tg, 'bk', 'sport')).to eq(0)
    expect(stats.group_canton_count(groups(:be).id, :another, 'bk', 'sport')).to eq(18)

    expect(stats.group_canton_count(groups(:fr).id, :be, 'bk', 'sport')).to eq(3)
    expect(stats.group_canton_count(groups(:fr).id, :ag, 'bk', 'sport')).to eq(3)
    expect(stats.group_canton_count(groups(:fr).id, :zh, 'bk', 'sport')).to eq(3)
    expect(stats.group_canton_count(groups(:fr).id, :tg, 'bk', 'sport')).to eq(3)
    expect(stats.group_canton_count(groups(:fr).id, :another, 'bk', 'sport')).to eq(3)

    expect(stats.group_canton_count(groups(:fr).id, :be, 'tk', 'sport')).to eq(2)
    expect(stats.group_canton_count(groups(:fr).id, :ag, 'tk', 'sport')).to eq(1)
    expect(stats.group_canton_count(groups(:fr).id, :zh, 'tk', 'sport')).to eq(1)
    expect(stats.group_canton_count(groups(:fr).id, :tg, 'tk', 'sport')).to eq(0)
    expect(stats.group_canton_count(groups(:fr).id, :another, 'tk', 'sport')).to eq(2)

    expect(stats.group_canton_count(groups(:be).id, :be, 'sk', 'sport')).to eq(0)
    expect(stats.group_canton_count(groups(:be).id, :another, 'sk', 'sport')).to eq(0)
    expect(stats.group_canton_count(groups(:fr).id, :be, 'sk', 'sport')).to eq(0)
    expect(stats.group_canton_count(groups(:fr).id, :another, 'sk', 'sport')).to eq(0)
  end

  private

  def create_course(year, group, leistungskategorie, challenged = {}, affiliated = {},
                    subventioniert = true, event_type = :course)
    event = nil
    if event_type == :aggregate_course
      event = Fabricate(event_type,
                        leistungskategorie: leistungskategorie,
                        fachkonzept: 'sport_jugend',
                        year: year)
      event.update!(group_ids: [groups(group).id])
    else
      event = Fabricate(event_type,
                        leistungskategorie: leistungskategorie,
                        fachkonzept: 'sport_jugend')
      event.update!(group_ids: [groups(group).id])
      event.dates.create!(start_at: Time.zone.local(year, 05, 11))
    end
    r = Event::CourseRecord.create!(
      event_id: event.id, year: year, subventioniert: subventioniert
    )
    r.create_challenged_canton_count!(challenged) if challenged.present?
    r.create_affiliated_canton_count!(affiliated) if affiliated.present?
    r.update!(teilnehmende_mehrfachbehinderte: challenged.values.sum / 3)
  end

end
