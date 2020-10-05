class AddBetreuungsstundenToEventCourseRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :event_course_records, :betreuungsstunden, :decimal, precision: 12, scale: 2
  end
end
