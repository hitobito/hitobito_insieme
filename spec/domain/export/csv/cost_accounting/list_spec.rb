# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'
require 'csv'

describe Export::Csv::CostAccounting::List do

  let(:group) { groups(:be) }
  let(:year) { 2015 }
  let(:table) { CostAccounting::Table.new(group, year) }
  let(:list) { described_class.new(table.reports.values) }
  let(:labels) { list.attribute_labels }

  context '#attribute_labels' do
    it 'contains attribute labels' do
      expect(labels[:report]).to eq 'Report'
      expect(labels[:kontengruppe]).to eq 'Kontengruppe'
      expect(labels[:aufwand_ertrag_fibu]).to eq 'Aufwand / Ertrag FIBU'
      expect(labels[:abgrenzung_fibu]).to eq 'Abgrenzungen FIBU'
      expect(labels[:abgrenzung_dachorganisation]).to eq 'Abgrenzung Dachorganisation'
      expect(labels[:aufwand_ertrag_ko_re]).to eq 'Kosten / Ertrag KoRe'
      expect(labels[:personal]).to eq 'Personal'
      expect(labels[:raeumlichkeiten]).to eq 'Räumlichkeiten'
      expect(labels[:verwaltung]).to eq 'Geschäftsführung'
      expect(labels[:beratung]).to eq 'Beratung'
      expect(labels[:treffpunkte]).to eq 'Treffpunkte'
      expect(labels[:blockkurse]).to eq 'Blockkurse'
      expect(labels[:tageskurse]).to eq 'Tageskurse'
      expect(labels[:jahreskurse]).to eq 'Jahreskurse'
      expect(labels[:lufeb]).to eq 'LUFEB'
      expect(labels[:mittelbeschaffung]).to eq 'Mittelbeschaffung'
      expect(labels[:total]).to eq 'Total'
      expect(labels[:kontrolle]).to eq 'Kontrolle'
    end
  end

  context '#to_csv' do
    before do
      create_report('raumaufwand', aufwand_ertrag_fibu: 20)
      create_report('leistungsertrag', aufwand_ertrag_fibu: 100)
    end

    let(:data) { [].tap { |csv| list.to_csv(csv) } }

    it 'contains all reports' do
      report_labels = data[1..-1].collect { |x| x.first }
      expect(report_labels).to match_array ['Lohnaufwand',
                                            'Sozialversicherungsaufwand',
                                            'Übriger Personalaufwand',
                                            'Honorare',
                                            'Total Personalaufwand/-kosten',
                                            'Raumaufwand',
                                            'Übriger Sachaufwand',
                                            'Abschreibungen (exkl. Liegenschaften)',
                                            'Total Aufwand/Kosten',
                                            'Umlage Personal',
                                            'Umlage Räumlichkeiten',
                                            'Umlage Verwaltung',
                                            'Total Umlagen',
                                            'Vollkosten nach Umlagen',
                                            'Leistungsertrag',
                                            'Beiträge IV',
                                            'Sonstige Beiträge Bund, Beiträge Kantone/Gemeinden',
                                            'Direkte Spenden, sonstige Erträge Art. 74',
                                            'Indirekte Spenden, sonstige Erträge (geschlüsselt)',
                                            'Direkte Spenden, sonstige Erträge ausserhalb Art. 74',
                                            'Total Erträge',
                                            'Deckungsbeitrag 1 (Leistungsertrag-direkte Kosten)',
                                            'Deckungsbeitrag 2 (DB 1 - Gemeinkosten + direkte Spenden / ' \
                                            'sonstige Erträge Art. 74 + indirekte Spenden / ' \
                                            'sonstige Erträge geschlüsselt)',
                                            'Deckungsbeitrag 3 (DB 2 + sonstige Beiträge Bund, Kantone, ' \
                                            'Gemeinden)',
                                            'Deckungsbeitrag 4 (DB 3 + Beiträge IV)',
                                            'Unternehmenserfolg']
    end

    it 'contains the values and calculations' do
      expect(data[6][2]).to eq 20
      expect(data[6][5]).to eq 20
      expect(data[9][2]).to eq 20
      expect(data[15][2]).to eq 100
      expect(data[15][5]).to eq 100
      expect(data[26][16]).to eq 80
    end
  end

  def create_report(name, values)
    CostAccountingRecord.create!(values.merge(group_id: group.id,
                                              year: year,
                                              report: name))
  end

end
