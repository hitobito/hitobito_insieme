# frozen_string_literal: true

#  Copyright (c) 2020-2021, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require "spec_helper"

describe Fp2020::CourseReporting::ClientStatistics do
  let(:year) { 2020 }
  let(:stats) { described_class.new(year) }

  before do
    create_course(year, :be, "bk",
      {be: 1, ag: 2, zh: 3, another: 4},
      {be: 0, ag: 1, zh: 1, another: 2})

    create_course(year, :be, "bk",
      {be: 2, ag: 4, zh: 6, another: 8},
      {be: 1, ag: 2, zh: 3, another: 4},
      true,
      :aggregate_course)

    create_course(year, :fr, "bk",
      {be: 3, ag: 3, zh: 3, tg: 3, another: 3})

    create_course(year, :fr, "tk",
      {be: 1, ag: 1, another: 1})

    create_course(year, :fr, "tk",
      {be: 1, zh: 1, another: 1})

    # other year
    create_course(year - 1, :fr, "bk",
      {be: 4, ag: 4, zh: 4, tg: 4, another: 4},
      {be: 2, ag: 2, zh: 2, another: 2})

    # same year, non subventioniert
    create_course(year, :be, "bk",
      {be: 1, ag: 2, zh: 3, another: 4},
      {be: 0, ag: 1, zh: 1, another: 2},
      false)
  end

  it "has a list of groups" do
    expect(stats.groups).to be_an Array
    expect(stats.groups.map(&:class).map(&:name).uniq).to eql ["Group::Dachverein",
      "Group::Regionalverein"]
    expect(stats.groups.map(&:name)).to eql [
      "insieme Schweiz",
      "Kanton Bern",
      "Biel-Seeland",
      "Freiburg"
    ]
  end

  it "knowns the cantons" do
    expect(stats.cantons).to eql %w[
      ag ai ar be bl bs fr ge gl gr ju lu ne
      nw ow sg sh so sz tg ti ur vd vs zg zh
      another
    ]
  end

  it "can load summed values" do
    expect(stats.send(:raw_group_canton_participants).size).to eq(3)
    rows = stats.send(:raw_group_canton_participants)
    gcps = rows.map do |row|
      Fp2020::CourseReporting::ClientStatistics::GroupCantonParticipant.new(*row)
    end

    expect(gcps.size).to eq(3)

    results = gcps.each_with_object({}) do |gcp, memo|
      memo[gcp.group_id] ||= {}
      memo[gcp.group_id][gcp.leistungskategorie] = gcp
    end

    expect(results).to be_a Hash
    expect(results.keys).to match_array [groups(:be).id, groups(:fr).id]

    expect(stats.send(:group_canton_participants).keys).to match_array [groups(:be).id,
      groups(:fr).id]
  end

  it "contains summed values per group" do
    # new style
    bern_bk = stats.group_participants(groups(:be).id, "bk", "sport")
    expect(bern_bk.be).to eq(4)
    expect(bern_bk.ag).to eq(9)
    expect(bern_bk.zh).to eq(13)
    expect(bern_bk.tg).to eq(0)
    expect(bern_bk.another).to eq(18)

    # old style, still supported
    expect(stats.group_canton_count(groups(:fr).id, :be, "bk", "sport")).to eq(3)
    expect(stats.group_canton_count(groups(:fr).id, :ag, "bk", "sport")).to eq(3)
    expect(stats.group_canton_count(groups(:fr).id, :zh, "bk", "sport")).to eq(3)
    expect(stats.group_canton_count(groups(:fr).id, :tg, "bk", "sport")).to eq(3)
    expect(stats.group_canton_count(groups(:fr).id, :another, "bk", "sport")).to eq(3)

    expect(stats.group_canton_count(groups(:fr).id, :be, "tk", "sport")).to eq(2)
    expect(stats.group_canton_count(groups(:fr).id, :ag, "tk", "sport")).to eq(1)
    expect(stats.group_canton_count(groups(:fr).id, :zh, "tk", "sport")).to eq(1)
    expect(stats.group_canton_count(groups(:fr).id, :tg, "tk", "sport")).to eq(0)
    expect(stats.group_canton_count(groups(:fr).id, :another, "tk", "sport")).to eq(2)

    expect(stats.group_canton_count(groups(:be).id, :be, "sk", "sport")).to eq(0)
    expect(stats.group_canton_count(groups(:be).id, :another, "sk", "sport")).to eq(0)
    expect(stats.group_canton_count(groups(:fr).id, :be, "sk", "sport")).to eq(0)
    expect(stats.group_canton_count(groups(:fr).id, :another, "sk", "sport")).to eq(0)
  end

  private

  # rubocop:todo Metrics/MethodLength
  # rubocop:todo Metrics/AbcSize
  def create_course(year, group, leistungskategorie, challenged = {}, affiliated = {},
    subventioniert = true, event_type = :course)
    event = nil
    if event_type == :aggregate_course
      event = Fabricate(event_type,
        leistungskategorie: leistungskategorie,
        fachkonzept: "sport_jugend",
        year: year)
      event.update!(group_ids: [groups(group).id])
    else
      event = Fabricate(event_type,
        leistungskategorie: leistungskategorie,
        fachkonzept: "sport_jugend")
      event.update!(group_ids: [groups(group).id])
      event.dates.create!(start_at: Time.zone.local(year, 0o5, 11))
    end
    r = Event::CourseRecord.create!(
      event_id: event.id, year: year, subventioniert: subventioniert
    )
    r.create_challenged_canton_count!(challenged) if challenged.present?
    r.create_affiliated_canton_count!(affiliated) if affiliated.present?
    r.update!(teilnehmende_mehrfachbehinderte: challenged.values.sum / 3)
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
