# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class ChangeCourseRecordTimeFieldsToDecimal < ActiveRecord::Migration
  def change
    change_column :event_course_records, :kurstage, :decimal, precision: 12, scale: 2
    change_column :event_course_records, :absenztage_behinderte, :decimal, precision: 12, scale: 2
    change_column :event_course_records, :absenztage_angehoerige, :decimal, precision: 12, scale: 2
    change_column :event_course_records, :absenztage_weitere, :decimal, precision: 12, scale: 2

    # rename absenztage_* to use time unit agnostic name (is used for days and hours)
    rename_column :event_course_records, :absenztage_behinderte, :absenzen_behinderte
    rename_column :event_course_records, :absenztage_angehoerige, :absenzen_angehoerige
    rename_column :event_course_records, :absenztage_weitere, :absenzen_weitere
  end
end
