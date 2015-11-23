# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class CostAccountingController < ReportingBaseController

  include ListController::Memory

  self.remember_params = [:year]

  helper_method :report, :table

  def index
    table
    respond_to do |format|
      format.html
      format.csv { render_csv }
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

  def table
    @table ||= CostAccounting::Table.new(group, year)
  end

  def permitted_params
    fields = report.editable_fields
    fields -= ['abgrenzung_dachorganisation'] unless group.is_a?(Group::Dachverein)
    params.require(:cost_accounting_record).permit(fields)
  end

  def render_csv
    csv = Export::Csv::CostAccounting::List.export(@table.reports.values)
    send_data csv, type: :csv, filename: csv_filename
  end

  def csv_filename
    vid = group.vid.present? && "_vid#{group.vid}" || ''
    bsv = group.bsv_number.present? && "_bsv#{group.bsv_number}" || ''
    "cost_accounting#{vid}#{bsv}_#{group.name.parameterize}_#{year}.csv"
  end

end
