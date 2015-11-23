# encoding: utf-8

module Export::Csv::Events
  class DetailRow < Export::Csv::Events::Row

    delegate *DetailList::ADD_COURSE_RECORD_ATTRS, to: :course_record, allow_nil: true

  end
end
