# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class CostAccountingController < ReportingBaseController

  helper_method :report

  def index
    @table = CostAccounting::Table.new(group, year)
  end

  private

  def entry
    @record ||= CostAccountingRecord.where(group_id: group.id, year: year, report: params[:report]).
                                     first_or_initialize
  end

  def report
    @report ||= entry.report_class || fail(ActiveRecord::RecordNotFound)
  end

  def permitted_params
    params.require(:cost_accounting_record).permit(report.editable_fields)
  end

end
