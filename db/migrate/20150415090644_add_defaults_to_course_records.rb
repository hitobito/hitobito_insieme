# encoding: utf-8

#  Copyright (c) 2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class AddDefaultsToCourseRecords < ActiveRecord::Migration
  def up
    Event::CourseRecord.where(subventioniert: nil).update_all(subventioniert: true)
    Event::CourseRecord.where(spezielle_unterkunft: nil).update_all(spezielle_unterkunft: false)
    change_column(:event_course_records, :subventioniert, :boolean, null: false, default: true)
    change_column(:event_course_records, :spezielle_unterkunft, :boolean, null: false, default: false)
  end

  def down
    change_column(:event_course_records, :subventioniert, :boolean)
    change_column(:event_course_records, :spezielle_unterkunft, :boolean)
  end
end
