# encoding: utf-8

#  Copyright (c) 2012-2015, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class ControllingController < ApplicationController

  extend ActiveModel::Callbacks
  include YearBasedPaging

  respond_to :html

  decorates :group

  helper_method :group

  before_action :authorize

  def index
    year
  end

  private

  def group
    @group ||= Group::Dachverein.find(params[:id])
  end

  def authorize
    authorize!(:controlling, group)
  end

end
