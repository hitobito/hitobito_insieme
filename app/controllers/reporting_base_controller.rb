# frozen_string_literal: true

#  Copyright (c) 2012-2020, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class ReportingBaseController < ApplicationController

  extend ActiveModel::Callbacks
  include YearBasedPaging

  define_model_callbacks :save

  layout 'reporting'

  respond_to :html

  decorates :group

  helper_method :entry, :group

  before_action :authorize
  before_action :entry

  after_save :set_success_notice

  def edit; end

  def update
    entry.attributes = permitted_params
    run_callbacks(:save) { entry.save }
    respond_with(entry, location: show_path)
  end

  private

  def set_success_notice
    flash[:notice] = I18n.t('crud.update.flash.success', model: entry)
  end

  def show_path
    if params['report'].present?
      cost_accounting_report_group_path(group, year, params['report'])
    else
      cost_accounting_group_path(group, year: year)
    end
  end

  def group
    @group ||= Group.find(params[:id])
  end

  def default_year
    @default_year ||= GlobalValue.default_reporting_year
  end

  def authorize
    authorize!(:reporting, group)
  end

end
