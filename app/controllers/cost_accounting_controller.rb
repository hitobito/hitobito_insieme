# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class CostAccountingController < ReportingBaseController

  include ListController::Memory

  self.remember_params = [:year]

  helper_method :report

  def index
    respond_to do |format|
      format.html { @table = CostAccounting::Table.new(group, year) }
      format.csv { render_entries_csv(CostAccounting::Table.new(group, year)) }
    end
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
    fields = report.editable_fields
    fields -= ['abgrenzung_dachorganisation'] unless group.is_a?(Group::Dachverein)
    params.require(:cost_accounting_record).permit(fields)
  end

  def render_entries_csv(table)
    render_csv(table.reports.values)
  end

  def render_csv(entries)
    send_data Export::Csv::CostAccounting::List.export(entries), type: :csv
  end
end
