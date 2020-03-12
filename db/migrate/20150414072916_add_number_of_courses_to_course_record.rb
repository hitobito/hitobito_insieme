# encoding: utf-8

#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AddNumberOfCoursesToCourseRecord < ActiveRecord::Migration[4.2]
  def change
    add_column :event_course_records, :anzahl_kurse, :integer, default: 1

    Event::CourseRecord.update_all(anzahl_kurse: 1)
  end
end
