# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class ReportingBaseController < ApplicationController
  include YearBasedPaging

  before_action :authorize

  layout 'reporting'

  decorates :group

  helper_method :record, :group

  before_action :record

  respond_to :html

  def edit
  end

  def update
    record.attributes = permitted_params

    if record.save
      flash[:notice] = I18n.t('crud.update.flash.success', model: record)
    end
    respond_with(record, location: cost_accounting_group_path(group, year: year))
  end

  private

  def group
    @group ||= Group.find(params[:id])
  end

  def authorize
    authorize!(:reporting, group)
  end
end
