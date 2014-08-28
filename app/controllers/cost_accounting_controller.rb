class CostAccountingController < ApplicationController

  include YearBasedPaging

  before_filter :authorize

  decorates :group

  helper_method :record, :report, :group

  respond_to :html

  def index
    @table = CostAccounting::Table.new(group, year)
  end

  def edit
    record
  end

  def update
    record.attributes = permitted_params
    success = record.save
    flash[:notice] = I18n.t('cost_accounting.update.flash.success', report: report.human_name) if success
    respond_with(record, location: cost_accounting_group_path(group, year: year))
  end

  private

  def record
    @record ||= CostAccountingRecord.where(group_id: group.id, year: year, report: params[:report]).
                                     first_or_initialize
  end

  def report
    @report ||= record.report_class || fail(ActiveRecord::RecordNotFound)
  end

  def group
    @group ||= Group.find(params[:id])
  end

  def permitted_params
    params.require(:cost_accounting_record).permit(report.editable_fields)
  end

  def authorize
    authorize!(:reporting, group)
  end

end
