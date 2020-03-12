# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class CreateCostAccountingModels < ActiveRecord::Migration[4.2]
  def change
    create_table :cost_accounting_records do |t|
      t.belongs_to :group, null: false
      t.integer :year, null: false
      t.string :report, null: false

      t.decimal :aufwand_ertrag_fibu, precision: 12, scale: 2
      t.decimal :abgrenzung_fibu, precision: 12, scale: 2
      t.decimal :abgrenzung_dachorganisation, precision: 12, scale: 2

      t.decimal :raeumlichkeiten, precision: 12, scale: 2
      t.decimal :verwaltung, precision: 12, scale: 2
      t.decimal :beratung, precision: 12, scale: 2
      t.decimal :treffpunkte, precision: 12, scale: 2
      t.decimal :blockkurse, precision: 12, scale: 2
      t.decimal :tageskurse, precision: 12, scale: 2
      t.decimal :jahreskurse, precision: 12, scale: 2
      t.decimal :lufeb, precision: 12, scale: 2
      t.decimal :mittelbeschaffung, precision: 12, scale: 2

      t.text :aufteilung_kontengruppen
    end

    add_index :cost_accounting_records, [:group_id, :year, :report], unique: true

    create_table :time_records do |t|
      t.belongs_to :group, null: false
      t.integer :year, null: false

      t.integer :verwaltung
      t.integer :beratung
      t.integer :treffpunkte
      t.integer :blockkurse
      t.integer :tageskurse
      t.integer :jahreskurse

      t.integer :kontakte_medien
      t.integer :interviews
      t.integer :publikationen
      t.integer :referate
      t.integer :medienkonferenzen
      t.integer :informationsveranstaltungen
      t.integer :sensibilisierungskampagnen
      t.integer :auskunftserteilung
      t.integer :kontakte_meinungsbildner
      t.integer :beratung_medien

      t.integer :eigene_zeitschriften
      t.integer :newsletter
      t.integer :informationsbroschueren
      t.integer :eigene_webseite

      t.integer :erarbeitung_instrumente
      t.integer :erarbeitung_grundlagen
      t.integer :projekte
      t.integer :vernehmlassungen
      t.integer :gremien

      t.integer :vermittlung_kontakte
      t.integer :unterstuetzung_selbsthilfeorganisationen
      t.integer :koordination_selbsthilfe
      t.integer :treffen_meinungsaustausch
      t.integer :beratung_fachhilfeorganisationen
      t.integer :unterstuetzung_behindertenhilfe

      t.integer :mittelbeschaffung
    end

    add_index :time_records, [:group_id, :year], unique: true
  end
end
