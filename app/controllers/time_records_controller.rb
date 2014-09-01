# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class TimeRecordsController < ReportingBaseController

  private

  def record
    @record ||= TimeRecord.where(group_id: group.id, year: year).first_or_initialize
  end

  def permitted_params
    params.require(:time_record).permit(TimeRecord.column_names - %w(id year group_id))
  end

end
