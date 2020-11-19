# frozen_string_literal: true

#  Copyright (c) 2020, Insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe Vp2020::CostAccounting::Aggregation do
  let(:year) { 2020 }
  subject { described_class.new(year) }

  let(:values) { subject.reports.values }

  context 'has assumptions, it' do
    it 'does not blow up' do
      expect(subject.year).to be 2020
    end

    it 'has a used API, returning [Vp2020::CostAccounting::Aggregation::Report]' do
      expect(values).to be_an Array
      expect(values.first).to be_a Vp2020::CostAccounting::Aggregation::Report
    end

    it 'has reports for each row (which then filtered in the export-class)' do
      expected_report_keys = %w[
        lohnaufwand
        sozialversicherungsaufwand
        uebriger_personalaufwand
        honorare
        total_personalaufwand
        raumaufwand
        uebriger_sachaufwand
        abschreibungen
        total_aufwand
        umlage_personal
        umlage_raeumlichkeiten
        umlage_verwaltung
        umlage_mittelbeschaffung
        total_umlagen
        vollkosten
        leistungsertrag
        beitraege_iv
        sonstige_beitraege
        direkte_spenden
        indirekte_spenden
        direkte_spenden_ausserhalb
        total_ertraege
        deckungsbeitrag1
        deckungsbeitrag2
        deckungsbeitrag3
        deckungsbeitrag4
        unternehmenserfolg
      ]

      actual_report_keys = subject.reports.keys

      expect(actual_report_keys).to match_array expected_report_keys
      expect(actual_report_keys).to eq expected_report_keys
    end
  end
end
