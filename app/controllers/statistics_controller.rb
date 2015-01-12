# encoding: utf-8

#  Copyright (c) 2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

class StatisticsController < ApplicationController

  before_action :authorize

  decorates :group

  respond_to :html

  def show
    @vereinsmitglieder = Statistics::Vereinsmitglieder.new

    respond_to do |format|
      format.html
      format.csv { send_data csv, type: :csv }
    end
  end

  private

  def csv
    Export::Csv::Statistics::Vereinsmitglieder.export(@vereinsmitglieder)
  end

  def group
    @group ||= Group::Dachverein.find(params[:id])
  end

  def authorize
    authorize!(:statistics, group)
  end
end
