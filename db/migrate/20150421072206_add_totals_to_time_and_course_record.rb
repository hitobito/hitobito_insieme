# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AddTotalsToTimeAndCourseRecord < ActiveRecord::Migration
  def change
    add_column :event_course_records, :total_tage_teilnehmende, :decimal,
               precision: 12, scale: 2
    Event::CourseRecord.reset_column_information

    # Cause sum_total_tage_teilnehmende to be called for each CourseRecord
    Event::CourseRecord.all.each do |record|
      record.save!
    end

    add_column :time_records, :total, :integer
    TimeRecord.reset_column_information

    # Cause update_totals to be called for each TimeRecord
    TimeRecord.all.each do |record|
      record.save!
    end
  end
end
