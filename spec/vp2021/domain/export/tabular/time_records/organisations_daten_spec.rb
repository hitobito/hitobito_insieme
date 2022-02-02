# frozen_string_literal: true

#  Copyright (c) 2021, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Vp2021::Export::Tabular::TimeRecords::OrganisationsDaten do
  let(:year) { 2021 }
  subject { described_class.new(data) }

  let(:teiler) { (1900 * 130).to_d }
  let(:data) do
    od = Vp2021::TimeRecord::OrganisationsDaten.new(year)
    verein_ids = od.vereine.map(&:id)

    od.instance_variable_set('@data_for', {
      verein_ids[0] => Vp2021::TimeRecord::OrganisationsDaten::Data.new(10, 5, 20, 8, 4, 123_500, 61_750, teiler),
      verein_ids[1] => Vp2021::TimeRecord::OrganisationsDaten::Data.new(*Array.new(7) {0}, teiler),
      verein_ids[2] => Vp2021::TimeRecord::OrganisationsDaten::Data.new(10, 5, 20, 7, 4, 0, 0, teiler),
      verein_ids[3] => Vp2021::TimeRecord::OrganisationsDaten::Data.new(*Array.new(7) {0}, teiler)
    })

    od
  end

  it 'has labels' do
    expected = ['Gruppe/Feldname', '']

    expect(subject.labels).to match_array expected
    expect(subject.labels).to eq expected
  end

  it 'has all the calculated values' do
    rows = subject.data_rows.take(18)

    expect(rows[ 0]).to be_all nil
    # all values
    expect(rows[ 1]).to eq ['insieme Schweiz',                                                       nil]
    expect(rows[ 2]).to eq ['FTE Angestellte MA insgesamt',                                         10.5]
    expect(rows[ 3]).to eq ['FTE Angestellte MA Betrieb Art. 74 IVG',                               5.25]
    expect(rows[ 4]).to eq ['FTE Freiwillig und ehrenamtlich Mitarbeitende insgesamt',                28]
    expect(rows[ 5]).to eq ['FTE Freiwillig und ehrenamtlich Mitarbeitende des Betriebes Art. 74 IVG', 4]
    expect(rows[ 6]).to be_all nil
    # no values
    expect(rows[ 7]).to eq ['Kanton Bern',                                                           nil]
    expect(rows[ 8]).to eq ['FTE Angestellte MA insgesamt',                                            0]
    expect(rows[ 9]).to eq ['FTE Angestellte MA Betrieb Art. 74 IVG',                                  0]
    expect(rows[10]).to eq ['FTE Freiwillig und ehrenamtlich Mitarbeitende insgesamt',                 0]
    expect(rows[11]).to eq ['FTE Freiwillig und ehrenamtlich Mitarbeitende des Betriebes Art. 74 IVG', 0]
    expect(rows[12]).to be_all nil
    # no honorar-ausgaben
    expect(rows[13]).to eq ['Biel-Seeland',                                                          nil]
    expect(rows[14]).to eq ['FTE Angestellte MA insgesamt',                                           10]
    expect(rows[15]).to eq ['FTE Angestellte MA Betrieb Art. 74 IVG',                                  5]
    expect(rows[16]).to eq ['FTE Freiwillig und ehrenamtlich Mitarbeitende insgesamt',                27]
    expect(rows[17]).to eq ['FTE Freiwillig und ehrenamtlich Mitarbeitende des Betriebes Art. 74 IVG', 4]
  end
end
