# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AddCourseReportsEvaluationFields < ActiveRecord::Migration[4.2]
  def change
    add_column :event_course_records, :year, :integer
    add_column :event_course_records, :teilnehmende_mehrfachbehinderte, :integer
    add_column :event_course_records, :total_direkte_kosten, :decimal, precision: 12, scale: 2
    add_column :event_course_records, :gemeinkostenanteil, :decimal, precision: 12, scale: 2
    add_column :event_course_records, :gemeinkosten_updated_at, :datetime
    add_column :event_course_records, :zugeteilte_kategorie, :string, limit: 2

    add_column :cost_accounting_parameters,
               :vollkosten_le_schwelle1_tageskurs,
               :decimal,
               null: false, precision: 12, scale: 2, default: 0
    add_column :cost_accounting_parameters,
               :vollkosten_le_schwelle2_tageskurs,
               :decimal,
               null: false, precision: 12, scale: 2, default: 0
  end
end
