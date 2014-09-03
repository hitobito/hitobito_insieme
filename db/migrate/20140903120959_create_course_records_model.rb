# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class CreateCourseRecordsModel < ActiveRecord::Migration
  def change
    create_table :event_course_records do |t|
      t.belongs_to :event, null: false

      t.string :inputkriterien, limit: 1
      t.boolean :subventioniert
      t.string :kursart

      t.integer :kurstage

      t.integer :teilnehmende_behinderte
      t.integer :teilnehmende_angehoerige
      t.integer :teilnehmende_weitere

      t.integer :absenztage_behinderte
      t.integer :absenztage_angehoerige
      t.integer :absenztage_weitere

      t.integer :leiterinnen
      t.integer :fachpersonen
      t.integer :hilfspersonal_ohne_honorar
      t.integer :hilfspersonal_mit_honorar

      t.integer :kuechenpersonal

      t.decimal :honorare_inkl_sozialversicherung, precision: 12, scale: 2
      t.decimal :unterkunft, precision: 12, scale: 2
      t.decimal :uebriges, precision: 12, scale: 2

      t.decimal :beitraege_teilnehmende, precision: 12, scale: 2
    end

    add_index :event_course_records, [:event_id], unique: true
  end
end
