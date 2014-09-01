# encoding: utf-8

#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class ReportingBaseController < ApplicationController
  include YearBasedPaging

  SUPPORTED_GROUPS = [Group::Dachverein,
                      Group::Regionalverein]


  before_action :authorize

  layout 'reporting'

  decorates :group

  helper_method :record, :group

  respond_to :html

  def edit
    @title = I18n.t('crud.edit.title', model: record)
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
    @group ||= Group.where(type: SUPPORTED_GROUPS).find(params[:id])
  end

  def authorize
    authorize!(:reporting, group)
  end
end
