# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class RenameCourseRecordKurstage < ActiveRecord::Migration[4.2]
  def change
    rename_column :event_course_records, :kurstage, :kursdauer
  end
end
