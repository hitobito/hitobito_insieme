class AddCourseRecordTotalDays < ActiveRecord::Migration[4.2]
  def up
    add_column :event_course_records, :tage_behinderte, :decimal, precision: 12, scale: 2
    add_column :event_course_records, :tage_angehoerige, :decimal, precision: 12, scale: 2
    add_column :event_course_records, :tage_weitere, :decimal, precision: 12, scale: 2

    rename_column :event_course_records, :total_direkte_kosten, :direkter_aufwand

    remove_column :event_course_records, :total_tage_teilnehmende

    Event::CourseRecord.reset_column_information

    Event::CourseRecord.find_each do |record|
      record.save!
    end
  end

  def down
    remove_column :event_course_records, :tage_behinderte
    remove_column :event_course_records, :tage_angehoerige
    remove_column :event_course_records, :tage_weitere

    rename_column :event_course_records, :direkter_aufwand, :total_direkte_kosten

    add_column :event_course_records, :total_tage_teilnehmende, :decimal,
               precision: 12, scale: 2, default: 0.0
  end
end
