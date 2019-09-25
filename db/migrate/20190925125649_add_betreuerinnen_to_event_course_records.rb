class AddBetreuerinnenToEventCourseRecords < ActiveRecord::Migration
  def change
    add_column :event_course_records, :betreuerinnen, :integer
  end
end
