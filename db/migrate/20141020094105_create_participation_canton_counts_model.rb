# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class CreateParticipationCantonCountsModel < ActiveRecord::Migration[4.2]
  def change
    create_table :event_participation_canton_counts do |t|
      t.integer :ag
      t.integer :ai
      t.integer :ar
      t.integer :be
      t.integer :bl
      t.integer :bs
      t.integer :fr
      t.integer :ge
      t.integer :gl
      t.integer :gr
      t.integer :ju
      t.integer :lu
      t.integer :ne
      t.integer :nw
      t.integer :ow
      t.integer :sg
      t.integer :sh
      t.integer :so
      t.integer :sz
      t.integer :tg
      t.integer :ti
      t.integer :ur
      t.integer :vd
      t.integer :vs
      t.integer :zg
      t.integer :zh
      t.integer :other
    end

    add_column :event_course_records, :challenged_canton_count_id, :integer
    add_column :event_course_records, :affiliated_canton_count_id, :integer
  end
end
