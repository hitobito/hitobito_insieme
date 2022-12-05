# frozen_string_literal: true

#  Copyright (c) 2012-2021, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class CostAccountingController < ReportingBaseController

  include Rememberable

  include Featureperioden::Domain
  include Featureperioden::Views

  self.remember_params = [:year]

  helper_method :report, :table, :previous_entry, :section_fields, :gemeinkosten_fields
  delegate :section_fields, :gemeinkosten_fields, to: :table

  before_action :table
  before_action :report, only: [:edit]

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to request.parameters.except(:report).merge({ action: index })
  end

  def index
    respond_to do |format|
      format.html
      format.xlsx { render_xlsx }
      format.pdf { render_pdf }
    end
  end

  private

  def entry
    @entry ||= CostAccountingRecord.where(group_id: group.id, year: year, report: params[:report])
                                   .first_or_initialize
  end

  def previous_entry
    @previous_entry ||= entry.class.where(
      group_id: group.id, year: (year - 1), report: params[:report]
    ).first_or_initialize
  end

  def report
    @report ||= entry.report_class || raise(ActiveRecord::RecordNotFound)
  end

  def table
    @table ||= fp_class('CostAccounting::Table').new(group, year)
  end

  def permitted_params
    fields = report.editable_fields
    fields -= ['abgrenzung_dachorganisation'] unless group.is_a?(Group::Dachverein)
    params.require(:cost_accounting_record).permit(fields)
  end

  def render_xlsx
    xlsx = fp_class('Export::Tabular::CostAccounting::List')
           .xlsx(@table.visible_reports.values, group.name, year)
    send_data xlsx, type: :xlsx, filename: export_filename(:xlsx)
  end

  def render_pdf
    pdf = fp_class('Export::Pdf::CostAccounting')
          .new(@table.visible_reports.values, group.name, year)
    send_data pdf.generate, type: :pdf, filename: export_filename(:pdf)
  end

  def export_filename(extension)
    "cost_accounting#{vid}#{bsv}_#{group.name.parameterize}_#{year}.#{extension}"
  end

  def vid
    group.vid.present? && "_vid#{group.vid}" || ''
  end

  def bsv
    group.bsv_number.present? && "_bsv#{group.bsv_number}" || ''
  end
end
